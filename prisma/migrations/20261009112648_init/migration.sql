-- CreateEnum
CREATE TYPE "FunnelType" AS ENUM ('paid', 'b2b', 'own');

-- CreateEnum
CREATE TYPE "ChannelStatus" AS ENUM ('active', 'paused', 'not_launched');

-- CreateEnum
CREATE TYPE "TagType" AS ENUM ('video', 'school', 'promoter', 'link', 'event', 'mailing');

-- CreateEnum
CREATE TYPE "EventType" AS ENUM ('main', 'school_based', 'final');

-- CreateEnum
CREATE TYPE "SchoolB2bStatus" AS ENUM ('not_contacted', 'in_progress', 'agreed', 'activated', 'declined');

-- CreateEnum
CREATE TYPE "LeadSource" AS ENUM ('form', 'whatsapp', 'call', 'event', 'import');

-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('new', 'qualified', 'registered', 'paid', 'rejected');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('kaspi_remote', 'other');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('paid', 'refunded');

-- CreateEnum
CREATE TYPE "PurchaseType" AS ENUM ('first', 'repeat');

-- CreateEnum
CREATE TYPE "ExpenseCategory" AS ENUM ('ads', 'promoters', 'print', 'cashback', 'prizes', 'event', 'other');

-- CreateEnum
CREATE TYPE "B2bActivityType" AS ENUM ('mailing', 'promo', 'quiz', 'school_olympiad');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('admin', 'manager', 'viewer');

-- CreateEnum
CREATE TYPE "ImportType" AS ENUM ('form_responses', 'payment_marks', 'meta_ads', 'olympiad_results', 'past_season');

-- CreateTable
CREATE TABLE "channel_groups" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "funnel_type" "FunnelType" NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "channel_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channels" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "group_id" INTEGER,
    "status" "ChannelStatus" NOT NULL DEFAULT 'not_launched',
    "funnel_type_override" "FunnelType",
    "owner" TEXT,
    "attribution_note" TEXT,
    "is_system" BOOLEAN NOT NULL DEFAULT false,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "channels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tags" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "type" "TagType" NOT NULL,
    "description" TEXT,
    "school_id" INTEGER,
    "active_from" DATE,
    "active_to" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "source_answers" (
    "id" SERIAL NOT NULL,
    "label" TEXT NOT NULL,
    "channel_id" INTEGER,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "source_answers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "olympiads" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "default_price" DECIMAL(14,2) NOT NULL,
    "az_share_pct" DECIMAL(5,2),
    "season_plan" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "olympiads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "events" (
    "id" SERIAL NOT NULL,
    "olympiad_id" INTEGER NOT NULL,
    "date" DATE,
    "city" TEXT NOT NULL DEFAULT 'Астана',
    "subject" TEXT,
    "type" "EventType" NOT NULL DEFAULT 'main',
    "venue_school_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "schools" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "city" TEXT NOT NULL DEFAULT 'Астана',
    "district" TEXT,
    "is_partner" BOOLEAN NOT NULL DEFAULT false,
    "zavuch_contact" TEXT,
    "special_price" DECIMAL(14,2),
    "cashback_amount" DECIMAL(14,2),
    "b2b_status" "SchoolB2bStatus" NOT NULL DEFAULT 'not_contacted',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "schools_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plans" (
    "id" SERIAL NOT NULL,
    "channel_id" INTEGER,
    "olympiad_id" INTEGER,
    "event_id" INTEGER,
    "period_from" DATE NOT NULL,
    "period_to" DATE NOT NULL,
    "planned_participations" INTEGER NOT NULL,
    "planned_spend" DECIMAL(14,2),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "families" (
    "id" SERIAL NOT NULL,
    "phone" TEXT NOT NULL,
    "parent_name" TEXT,
    "email" TEXT,
    "first_touch_channel_id" INTEGER,
    "first_touch_tag_id" INTEGER,
    "first_touch_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "families_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "children" (
    "id" SERIAL NOT NULL,
    "family_id" INTEGER NOT NULL,
    "iin_hash" TEXT,
    "first_name" TEXT NOT NULL,
    "grade" INTEGER,
    "school_id" INTEGER,
    "school_name" TEXT,
    "language" TEXT,
    "teacher_phone" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "children_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leads" (
    "id" SERIAL NOT NULL,
    "family_id" INTEGER NOT NULL,
    "olympiad_id" INTEGER,
    "source" "LeadSource" NOT NULL,
    "raw_tag_code" TEXT,
    "tag_id" INTEGER,
    "how_heard" TEXT,
    "answer_channel_id" INTEGER,
    "channel_id" INTEGER NOT NULL,
    "needs_review" BOOLEAN NOT NULL DEFAULT false,
    "status" "LeadStatus" NOT NULL DEFAULT 'new',
    "reject_reason" TEXT,
    "lead_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "raw_message" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "leads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "registrations" (
    "id" SERIAL NOT NULL,
    "child_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "lead_id" INTEGER,
    "registered_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "form_response_id" TEXT,
    "consent_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "registrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" SERIAL NOT NULL,
    "family_id" INTEGER,
    "amount" DECIMAL(14,2) NOT NULL,
    "paid_at" DATE NOT NULL,
    "method" "PaymentMethod" NOT NULL DEFAULT 'kaspi_remote',
    "payer_phone" TEXT,
    "marked_by_id" INTEGER,
    "status" "PaymentStatus" NOT NULL DEFAULT 'paid',
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "participations" (
    "id" SERIAL NOT NULL,
    "child_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "registration_id" INTEGER,
    "payment_id" INTEGER NOT NULL,
    "actual_price" DECIMAL(14,2) NOT NULL,
    "attended" BOOLEAN,
    "score_pct" DECIMAL(5,2),
    "is_finalist" BOOLEAN,
    "purchase_type" "PurchaseType" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "participations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" SERIAL NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "tag_id" INTEGER,
    "category" "ExpenseCategory" NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "period_from" DATE NOT NULL,
    "period_to" DATE NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ad_stats" (
    "id" SERIAL NOT NULL,
    "tag_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "ad_name" TEXT,
    "impressions" INTEGER NOT NULL DEFAULT 0,
    "clicks" INTEGER NOT NULL DEFAULT 0,
    "chats_started" INTEGER NOT NULL DEFAULT 0,
    "spend" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "import_batch_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ad_stats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "b2b_activity" (
    "id" SERIAL NOT NULL,
    "school_id" INTEGER NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "type" "B2bActivityType" NOT NULL,
    "date" DATE NOT NULL,
    "reach_classes" INTEGER,
    "reach_children" INTEGER,
    "reach_parent_chats" INTEGER,
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "b2b_activity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reach_stats" (
    "id" SERIAL NOT NULL,
    "channel_id" INTEGER NOT NULL,
    "tag_id" INTEGER,
    "date" DATE NOT NULL,
    "contacts" INTEGER,
    "reached" INTEGER,
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reach_stats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settings" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "target_cps" DECIMAL(14,2) NOT NULL DEFAULT 5000,
    "cashback_per_participant" DECIMAL(14,2) NOT NULL DEFAULT 5000,
    "hint_off_cps_multiplier" DECIMAL(6,2) NOT NULL DEFAULT 2,
    "hint_scale_min_payments" INTEGER NOT NULL DEFAULT 5,
    "plan_warn_pct" DECIMAL(5,2) NOT NULL DEFAULT 70,
    "unknown_warn_pct" DECIMAL(5,2) NOT NULL DEFAULT 10,
    "unpaid_reminder_days" INTEGER NOT NULL DEFAULT 2,
    "finalist_threshold_pct" DECIMAL(5,2) NOT NULL DEFAULT 50,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "password_hash" TEXT NOT NULL,
    "totp_secret" TEXT,
    "totp_enabled" BOOLEAN NOT NULL DEFAULT false,
    "role" "UserRole" NOT NULL DEFAULT 'admin',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "last_login_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_batches" (
    "id" SERIAL NOT NULL,
    "type" "ImportType" NOT NULL,
    "file_name" TEXT,
    "user_id" INTEGER,
    "rows_total" INTEGER NOT NULL DEFAULT 0,
    "rows_new" INTEGER NOT NULL DEFAULT 0,
    "rows_dup" INTEGER NOT NULL DEFAULT 0,
    "rows_error" INTEGER NOT NULL DEFAULT 0,
    "committed_at" TIMESTAMP(3),
    "errors" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "import_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "action" TEXT NOT NULL,
    "entity" TEXT,
    "entity_id" TEXT,
    "changes" JSONB,
    "ip" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "channel_groups_code_key" ON "channel_groups"("code");

-- CreateIndex
CREATE UNIQUE INDEX "channels_code_key" ON "channels"("code");

-- CreateIndex
CREATE UNIQUE INDEX "tags_code_key" ON "tags"("code");

-- CreateIndex
CREATE INDEX "tags_channel_id_idx" ON "tags"("channel_id");

-- CreateIndex
CREATE UNIQUE INDEX "source_answers_label_key" ON "source_answers"("label");

-- CreateIndex
CREATE UNIQUE INDEX "olympiads_code_key" ON "olympiads"("code");

-- CreateIndex
CREATE INDEX "events_olympiad_id_date_idx" ON "events"("olympiad_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "schools_name_city_key" ON "schools"("name", "city");

-- CreateIndex
CREATE UNIQUE INDEX "families_phone_key" ON "families"("phone");

-- CreateIndex
CREATE INDEX "families_first_touch_channel_id_idx" ON "families"("first_touch_channel_id");

-- CreateIndex
CREATE UNIQUE INDEX "children_iin_hash_key" ON "children"("iin_hash");

-- CreateIndex
CREATE INDEX "children_family_id_idx" ON "children"("family_id");

-- CreateIndex
CREATE INDEX "leads_family_id_idx" ON "leads"("family_id");

-- CreateIndex
CREATE INDEX "leads_channel_id_lead_at_idx" ON "leads"("channel_id", "lead_at");

-- CreateIndex
CREATE INDEX "leads_status_idx" ON "leads"("status");

-- CreateIndex
CREATE UNIQUE INDEX "registrations_form_response_id_key" ON "registrations"("form_response_id");

-- CreateIndex
CREATE INDEX "registrations_lead_id_idx" ON "registrations"("lead_id");

-- CreateIndex
CREATE UNIQUE INDEX "registrations_child_id_event_id_key" ON "registrations"("child_id", "event_id");

-- CreateIndex
CREATE INDEX "payments_paid_at_idx" ON "payments"("paid_at");

-- CreateIndex
CREATE UNIQUE INDEX "participations_registration_id_key" ON "participations"("registration_id");

-- CreateIndex
CREATE INDEX "participations_payment_id_idx" ON "participations"("payment_id");

-- CreateIndex
CREATE UNIQUE INDEX "participations_child_id_event_id_key" ON "participations"("child_id", "event_id");

-- CreateIndex
CREATE INDEX "expenses_channel_id_period_from_idx" ON "expenses"("channel_id", "period_from");

-- CreateIndex
CREATE UNIQUE INDEX "ad_stats_tag_id_date_key" ON "ad_stats"("tag_id", "date");

-- CreateIndex
CREATE INDEX "b2b_activity_school_id_date_idx" ON "b2b_activity"("school_id", "date");

-- CreateIndex
CREATE INDEX "reach_stats_channel_id_date_idx" ON "reach_stats"("channel_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "audit_log_created_at_idx" ON "audit_log"("created_at");

-- CreateIndex
CREATE INDEX "audit_log_entity_entity_id_idx" ON "audit_log"("entity", "entity_id");

-- AddForeignKey
ALTER TABLE "channels" ADD CONSTRAINT "channels_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "channel_groups"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tags" ADD CONSTRAINT "tags_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tags" ADD CONSTRAINT "tags_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "schools"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "source_answers" ADD CONSTRAINT "source_answers_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_olympiad_id_fkey" FOREIGN KEY ("olympiad_id") REFERENCES "olympiads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_venue_school_id_fkey" FOREIGN KEY ("venue_school_id") REFERENCES "schools"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "plans" ADD CONSTRAINT "plans_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "plans" ADD CONSTRAINT "plans_olympiad_id_fkey" FOREIGN KEY ("olympiad_id") REFERENCES "olympiads"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "plans" ADD CONSTRAINT "plans_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "families" ADD CONSTRAINT "families_first_touch_channel_id_fkey" FOREIGN KEY ("first_touch_channel_id") REFERENCES "channels"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "families" ADD CONSTRAINT "families_first_touch_tag_id_fkey" FOREIGN KEY ("first_touch_tag_id") REFERENCES "tags"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "children" ADD CONSTRAINT "children_family_id_fkey" FOREIGN KEY ("family_id") REFERENCES "families"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "children" ADD CONSTRAINT "children_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "schools"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_family_id_fkey" FOREIGN KEY ("family_id") REFERENCES "families"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_olympiad_id_fkey" FOREIGN KEY ("olympiad_id") REFERENCES "olympiads"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_answer_channel_id_fkey" FOREIGN KEY ("answer_channel_id") REFERENCES "channels"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registrations" ADD CONSTRAINT "registrations_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registrations" ADD CONSTRAINT "registrations_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registrations" ADD CONSTRAINT "registrations_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_family_id_fkey" FOREIGN KEY ("family_id") REFERENCES "families"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_marked_by_id_fkey" FOREIGN KEY ("marked_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participations" ADD CONSTRAINT "participations_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participations" ADD CONSTRAINT "participations_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participations" ADD CONSTRAINT "participations_registration_id_fkey" FOREIGN KEY ("registration_id") REFERENCES "registrations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participations" ADD CONSTRAINT "participations_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ad_stats" ADD CONSTRAINT "ad_stats_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ad_stats" ADD CONSTRAINT "ad_stats_import_batch_id_fkey" FOREIGN KEY ("import_batch_id") REFERENCES "import_batches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "b2b_activity" ADD CONSTRAINT "b2b_activity_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "schools"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "b2b_activity" ADD CONSTRAINT "b2b_activity_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reach_stats" ADD CONSTRAINT "reach_stats_channel_id_fkey" FOREIGN KEY ("channel_id") REFERENCES "channels"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reach_stats" ADD CONSTRAINT "reach_stats_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "import_batches" ADD CONSTRAINT "import_batches_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
