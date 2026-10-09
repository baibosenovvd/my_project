// Стартовые данные: группы и 22 канала из карты каналов, ответы «Откуда узнали»,
// олимпиады и даты, школа Zerdeli, постоянные метки, настройки.
// Повторный запуск безопасен: всё через upsert по коду.

import { PrismaClient, ChannelStatus, FunnelType, TagType, EventType } from "@prisma/client";

const prisma = new PrismaClient();

const { active, paused, not_launched } = ChannelStatus;

const groups: { code: string; name: string; funnelType: FunnelType }[] = [
  { code: "A", name: "Школы и партнёрства (B2B)", funnelType: "b2b" },
  { code: "B", name: "Офлайн и прямой контакт", funnelType: "b2b" },
  { code: "C", name: "Платные каналы", funnelType: "paid" },
  { code: "D", name: "Свои медиа", funnelType: "own" },
  { code: "E", name: "Работа с базой", funnelType: "own" },
  { code: "F", name: "Лид-магнит", funnelType: "own" },
];

type ChannelSeed = {
  code: string;
  group: string;
  name: string;
  status: ChannelStatus;
  note: string;
  funnelTypeOverride?: FunnelType;
};

// Статусы из карты: ✅ и ⚠️ «не системно» → active; ⏳ и ❌ → not_launched; ⏸ и ⛔ → paused
const channels: ChannelSeed[] = [
  // A. Школы и партнёрства (B2B)
  { code: "ASTANA_DARYNY", group: "A", name: "«Астана дарыны»: рассылка всем завучам Астаны", status: active, note: "Поле «Откуда узнали» в форме" },
  { code: "ZAVUCH", group: "A", name: "Завучи школ-партнёров: рассылки в родительские чаты", status: active, note: "Поле «Школа» (выпадающий список партнёров). Кэшбек 5 000 ₸ за участника" },
  { code: "SCHOOL_OLYMPIAD", group: "A", name: "Олимпиада на базе школы (доп. даты)", status: active, note: "Число школ × участники на школу" },
  { code: "TEACHER", group: "A", name: "Учителя-координаторы", status: not_launched, note: "Поле «Телефон учителя» в форме" },
  { code: "REGIONS", group: "A", name: "Региональные партнёры (Алматы, Шымкент, Караганда)", status: not_launched, note: "Город в форме" },
  // B. Офлайн и прямой контакт
  { code: "PROMO", group: "B", name: "Промо: промоутеры в классах + флаеры", status: active, note: "Таблица промоутера + «Откуда узнали: промоутер»" },
  { code: "QUIZ", group: "B", name: "Квизы в школах", status: not_launched, note: "Участники квиза → заявки по школе" },
  { code: "EXPO", group: "B", name: "Выставки", status: active, note: "«Откуда узнали: выставка»", funnelTypeOverride: "own" },
  { code: "EVENTS", group: "B", name: "Свои мероприятия (BilimTalks, Global EdTech, Robocoach)", status: not_launched, note: "Контакты учителей и школ с мероприятия", funnelTypeOverride: "own" },
  // C. Платные каналы
  { code: "TARGET_META", group: "C", name: "Таргет Instagram / Facebook", status: not_launched, note: "WhatsApp-заявки с меткой кампании → оплата. Холодные / тёплые / дедлайн" },
  { code: "TIKTOK", group: "C", name: "TikTok Ads", status: not_launched, note: "Отдельная метка в заявке. Тест 10–15% бюджета" },
  { code: "INFLUENCERS", group: "C", name: "Инфлюенсеры", status: paused, note: "Пока без них" },
  { code: "SEARCH", group: "C", name: "Поисковая реклама", status: paused, note: "Не делаем" },
  // D. Свои медиа
  { code: "INSTAGRAM", group: "D", name: "Instagram @azgroup.kz и @fibonacci.olympiads.kz", status: active, note: "Клики по ссылке в профиле, «Откуда узнали: Instagram»" },
  { code: "TELEGRAM", group: "D", name: "Telegram-канал", status: active, note: "Переходы по ссылке из канала (~800 подписчиков)" },
  { code: "SITE", group: "D", name: "Сайты fibonacci / atlantia / az-group", status: active, note: "Переходы на форму, UTM" },
  { code: "WHATSAPP", group: "D", name: "WhatsApp: отдел продаж и рассылки по базе", status: active, note: "Обращения → оплаты" },
  // E. Работа с базой
  { code: "BASE_2025", group: "E", name: "Реактивация прошлогодних участников", status: not_launched, note: "Совпадение с базой прошлого сезона (~1 000 семей)" },
  { code: "CROSS_SELL", group: "E", name: "Кросс-продажа Fibonacci ↔ Atlantia, второй предмет", status: not_launched, note: "Участники с 2+ олимпиадами или предметами" },
  { code: "FINALISTS", group: "E", name: "Финалисты → финал → лагеря и обмен", status: active, note: "Конверсия в оплату финала" },
  { code: "REFERRAL", group: "E", name: "Сарафан и «приведи друга»", status: active, note: "«Откуда узнали: друзья» / промокод" },
  // F. Лид-магнит
  { code: "TRIAL_ONLINE", group: "F", name: "Бесплатная пробная олимпиада онлайн", status: not_launched, note: "Прошли пробник → записались" },
];

// Варианты в Google Форме, в том же порядке. null — канал не определяется (UNKNOWN)
const sourceAnswers: [label: string, channelCode: string | null][] = [
  ["От завуча или учителя", "ZAVUCH"],
  ["Из чата родителей школы", "ZAVUCH"],
  ["Промоутер в школе", "PROMO"],
  ["Реклама в Instagram", "TARGET_META"],
  ["TikTok", "TIKTOK"],
  ["Наш Instagram", "INSTAGRAM"],
  ["Telegram", "TELEGRAM"],
  ["Сайт", "SITE"],
  ["Выставка или мероприятие", "EXPO"],
  ["Друзья и знакомые", "REFERRAL"],
  ["Участвовали раньше", "BASE_2025"],
  ["Другое", null],
];

// Постоянные метки из примеров ТЗ. Метки роликов и промоутеров заводятся по ходу работы
const tags: { code: string; channel: string; type: TagType; description: string; school?: string }[] = [
  { code: "DARYN", channel: "ASTANA_DARYNY", type: "link", description: "Ссылка на форму в рассылке «Астана дарыны»" },
  { code: "SCH-ZERDELI", channel: "ZAVUCH", type: "school", description: "Школа Zerdeli", school: "Zerdeli" },
  { code: "IG-FIB", channel: "INSTAGRAM", type: "link", description: "Ссылка в профиле @fibonacci.olympiads.kz" },
  { code: "TG", channel: "TELEGRAM", type: "link", description: "Ссылка в Telegram-канале" },
  { code: "SITE-FIB", channel: "SITE", type: "link", description: "Кнопка записи на сайте Fibonacci" },
];

const d = (iso: string) => new Date(`${iso}T00:00:00Z`);

async function main() {
  for (const [i, g] of groups.entries()) {
    await prisma.channelGroup.upsert({
      where: { code: g.code },
      update: { name: g.name, funnelType: g.funnelType, sortOrder: i },
      create: { ...g, sortOrder: i },
    });
  }
  const groupId = Object.fromEntries(
    (await prisma.channelGroup.findMany()).map((g) => [g.code, g.id]),
  );

  for (const [i, c] of channels.entries()) {
    const data = {
      name: c.name,
      groupId: groupId[c.group],
      status: c.status,
      attributionNote: c.note,
      funnelTypeOverride: c.funnelTypeOverride ?? null,
      sortOrder: i,
    };
    await prisma.channel.upsert({ where: { code: c.code }, update: data, create: { code: c.code, ...data } });
  }
  // Служебный канал: нет ни кода, ни ответа (правило 4)
  await prisma.channel.upsert({
    where: { code: "UNKNOWN" },
    update: {},
    create: { code: "UNKNOWN", name: "Источник не определён", status: active, isSystem: true, sortOrder: 999 },
  });
  const channelId = Object.fromEntries(
    (await prisma.channel.findMany()).map((c) => [c.code, c.id]),
  );

  for (const [i, [label, code]] of sourceAnswers.entries()) {
    const data = { channelId: code ? channelId[code] : null, sortOrder: i };
    await prisma.sourceAnswer.upsert({ where: { label }, update: data, create: { label, ...data } });
  }

  const zerdeli = await prisma.school.upsert({
    where: { name_city: { name: "Zerdeli", city: "Астана" } },
    update: {},
    create: { name: "Zerdeli", isPartner: true, specialPrice: 20000, b2bStatus: "agreed" },
  });

  for (const t of tags) {
    const data = {
      channelId: channelId[t.channel],
      type: t.type,
      description: t.description,
      schoolId: t.school ? zerdeli.id : null,
    };
    await prisma.tag.upsert({ where: { code: t.code }, update: data, create: { code: t.code, ...data } });
  }

  // Доля AZ GROUP не задана — открытый вопрос ТЗ; пока ROMI считается по выручке
  const fibonacci = await prisma.olympiad.upsert({
    where: { code: "FIBONACCI" },
    update: {},
    create: { code: "FIBONACCI", name: "Fibonacci", defaultPrice: 25000, seasonPlan: 10000 },
  });
  const atlantia = await prisma.olympiad.upsert({
    where: { code: "ATLANTIA" },
    update: {},
    create: { code: "ATLANTIA", name: "Atlantia", defaultPrice: 25000, seasonPlan: 10000 },
  });

  // Даты создаются только в пустой базе: у событий нет естественного ключа
  if ((await prisma.event.count()) === 0) {
    await prisma.event.createMany({
      data: [
        ...["2026-10-17", "2026-11-14", "2026-12-19", "2027-02-13"].map((date) => ({
          olympiadId: fibonacci.id,
          date: d(date),
          subject: "Математика",
        })),
        { olympiadId: fibonacci.id, date: null, subject: "Математика", type: EventType.final },
        // TODO: 5 предметов Atlantia в ТЗ не названы. Нужна отдельная дата на каждый предмет,
        // иначе ребёнок не сможет записаться на два предмета (уникальность ребёнок + событие)
        { olympiadId: atlantia.id, date: d("2026-10-24"), subject: null },
        { olympiadId: atlantia.id, date: null, subject: null, type: EventType.final },
      ],
    });
  }

  await prisma.setting.upsert({ where: { id: 1 }, update: {}, create: { id: 1 } });

  const counts = {
    groups: await prisma.channelGroup.count(),
    channels: await prisma.channel.count({ where: { isSystem: false } }),
    sourceAnswers: await prisma.sourceAnswer.count(),
    tags: await prisma.tag.count(),
    events: await prisma.event.count(),
  };
  console.log("Сиды загружены:", counts);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
