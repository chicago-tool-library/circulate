# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_04_163403) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_enum :adjustment_kind, [
    "fine",
    "membership",
    "donation",
    "payment",
  ], force: :cascade

  create_enum :adjustment_source, [
    "cash",
    "square",
    "forgiveness",
  ], force: :cascade

  create_enum :answer_type, [
    "text",
    "integer",
  ], force: :cascade

  create_enum :borrow_policy_approval_status, [
    "approved",
    "rejected",
    "requested",
    "revoked",
  ], force: :cascade

  create_enum :item_attachment_kind, [
    "manual",
    "parts_list",
    "other",
  ], force: :cascade

  create_enum :item_status, [
    "pending",
    "active",
    "maintenance",
    "retired",
    "missing",
  ], force: :cascade

  create_enum :membership_type, [
    "initial",
    "renewal",
  ], force: :cascade

  create_enum :organization_member_role, [
    "admin",
    "member",
  ], force: :cascade

  create_enum :power_source, [
    "solar",
    "gas",
    "air",
    "electric (corded)",
    "electric (battery)",
  ], force: :cascade

  create_enum :renewal_request_status, [
    "requested",
    "approved",
    "rejected",
  ], force: :cascade

  create_enum :reservation_status, [
    "pending",
    "requested",
    "approved",
    "rejected",
    "obsolete",
    "building",
    "ready",
    "borrowed",
    "returned",
    "unresolved",
    "cancelled",
  ], force: :cascade

  create_enum :ticket_status, [
    "assess",
    "parts",
    "repairing",
    "resolved",
    "retired",
  ], force: :cascade

  create_enum :user_role, [
    "staff",
    "admin",
    "member",
    "super_admin",
  ], force: :cascade

  create_enum :adjustment_kind, [
    "fine",
    "membership",
    "donation",
    "payment",
  ], force: :cascade

  create_enum :adjustment_source, [
    "cash",
    "square",
    "forgiveness",
  ], force: :cascade

  create_enum :answer_type, [
    "text",
    "integer",
  ], force: :cascade

  create_enum :borrow_policy_approval_status, [
    "approved",
    "rejected",
    "requested",
    "revoked",
  ], force: :cascade

  create_enum :item_attachment_kind, [
    "manual",
    "parts_list",
    "other",
  ], force: :cascade

  create_enum :item_status, [
    "pending",
    "active",
    "maintenance",
    "retired",
    "missing",
  ], force: :cascade

  create_enum :membership_type, [
    "initial",
    "renewal",
  ], force: :cascade

  create_enum :organization_member_role, [
    "admin",
    "member",
  ], force: :cascade

  create_enum :power_source, [
    "solar",
    "gas",
    "air",
    "electric (corded)",
    "electric (battery)",
  ], force: :cascade

  create_enum :renewal_request_status, [
    "requested",
    "approved",
    "rejected",
  ], force: :cascade

  create_enum :reservation_status, [
    "pending",
    "requested",
    "approved",
    "rejected",
    "obsolete",
    "building",
    "ready",
    "borrowed",
    "returned",
    "unresolved",
    "cancelled",
  ], force: :cascade

  create_enum :ticket_status, [
    "assess",
    "parts",
    "repairing",
    "resolved",
    "retired",
  ], force: :cascade

  create_enum :user_role, [
    "staff",
    "admin",
    "member",
    "super_admin",
  ], force: :cascade

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "adjustments", force: :cascade do |t|
    t.string "adjustable_type"
    t.bigint "adjustable_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "payment_source", enum_type: "adjustment_source"
    t.string "square_transaction_id"
    t.enum "kind", null: false, enum_type: "adjustment_kind"
    t.index ["adjustable_type", "adjustable_id"], name: "index_adjustments_on_adjustable_type_and_adjustable_id"
    t.index ["member_id"], name: "index_adjustments_on_member_id"
  end

  create_table "agreement_acceptances", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_agreement_acceptances_on_member_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "answers", force: :cascade do |t|
    t.bigint "stem_id", null: false
    t.bigint "reservation_id", null: false
    t.jsonb "result", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_answers_on_reservation_id"
    t.index ["stem_id", "reservation_id"], name: "index_answers_on_stem_id_and_reservation_id", unique: true
    t.index ["stem_id"], name: "index_answers_on_stem_id"
  end

  create_table "appointment_holds", force: :cascade do |t|
    t.bigint "appointment_id"
    t.bigint "hold_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_holds_on_appointment_id"
    t.index ["hold_id"], name: "index_appointment_holds_on_hold_id"
  end

  create_table "appointment_loans", force: :cascade do |t|
    t.bigint "appointment_id"
    t.bigint "loan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_loans_on_appointment_id"
    t.index ["loan_id"], name: "index_appointment_loans_on_loan_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "starts_at", precision: nil, null: false
    t.datetime "ends_at", precision: nil, null: false
    t.text "comment", default: "", null: false
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completed_at", precision: nil
    t.datetime "pulled_at", precision: nil
    t.index ["member_id"], name: "index_appointments_on_member_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "borrow_policies", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration", default: 7, null: false
    t.integer "fine_cents", default: 0, null: false
    t.string "fine_currency", default: "USD", null: false
    t.integer "fine_period", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "uniquely_numbered", default: true, null: false
    t.string "code", null: false
    t.string "description"
    t.boolean "default", default: false, null: false
    t.integer "renewal_limit", default: 0, null: false
    t.boolean "member_renewable", default: false, null: false
    t.integer "library_id"
    t.boolean "consumable", default: false
    t.boolean "requires_approval", default: false, null: false
    t.index ["code", "library_id"], name: "index_borrow_policies_on_code_and_library_id", unique: true
    t.index ["library_id", "name"], name: "index_borrow_policies_on_library_id_and_name", unique: true
  end

  create_table "borrow_policy_approvals", force: :cascade do |t|
    t.bigint "borrow_policy_id", null: false
    t.bigint "member_id", null: false
    t.enum "status", default: "requested", null: false, enum_type: "borrow_policy_approval_status"
    t.text "status_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrow_policy_id", "member_id"], name: "idx_on_borrow_policy_id_member_id_f2459be3a6", unique: true
    t.index ["borrow_policy_id"], name: "index_borrow_policy_approvals_on_borrow_policy_id"
    t.index ["member_id"], name: "index_borrow_policy_approvals_on_member_id"
    t.index ["status"], name: "index_borrow_policy_approvals_on_status"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "categorizations_count", default: 0, null: false
    t.bigint "parent_id"
    t.integer "library_id"
    t.index ["library_id", "name"], name: "index_categories_on_library_id_and_name", unique: true
    t.index ["library_id", "slug"], name: "index_categories_on_library_id_and_slug", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "categorizations", force: :cascade do |t|
    t.bigint "categorized_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "categorized_type", null: false
    t.index ["categorized_id"], name: "index_categorizations_on_categorized_id"
    t.index ["category_id", "categorized_id"], name: "index_categorizations_on_category_id_and_categorized_id", unique: true
    t.index ["category_id"], name: "index_categorizations_on_category_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name", null: false
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.integer "library_id"
    t.index ["library_id", "code"], name: "index_documents_on_library_id_and_code"
  end

  create_table "events", force: :cascade do |t|
    t.string "calendar_id", null: false
    t.string "calendar_event_id", null: false
    t.datetime "start", precision: nil, null: false
    t.datetime "finish", precision: nil, null: false
    t.string "summary"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "attendees"
    t.integer "library_id"
    t.index ["calendar_id", "calendar_event_id"], name: "index_events_on_calendar_id_and_calendar_event_id", unique: true
    t.index ["library_id"], name: "index_events_on_library_id"
  end

  create_table "gift_memberships", force: :cascade do |t|
    t.string "purchaser_email", null: false
    t.string "purchaser_name", null: false
    t.integer "amount_cents", null: false
    t.string "code", null: false
    t.bigint "membership_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_name"
    t.integer "library_id"
    t.index ["library_id", "code"], name: "index_gift_memberships_on_library_id_and_code", unique: true
    t.index ["membership_id"], name: "index_gift_memberships_on_membership_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "holds", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "item_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at", precision: nil
    t.bigint "loan_id"
    t.datetime "started_at", precision: nil
    t.integer "library_id"
    t.datetime "expires_at", precision: nil
    t.integer "position", null: false
    t.index ["creator_id"], name: "index_holds_on_creator_id"
    t.index ["item_id", "position"], name: "index_holds_on_item_id_and_position", unique: true
    t.index ["item_id"], name: "index_holds_on_item_id"
    t.index ["library_id"], name: "index_holds_on_library_id"
    t.index ["loan_id"], name: "index_holds_on_loan_id"
    t.index ["member_id"], name: "index_holds_on_member_id"
  end

  create_table "item_attachments", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "creator_id", null: false
    t.enum "kind", enum_type: "item_attachment_kind"
    t.string "other_kind"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_item_attachments_on_creator_id"
    t.index ["item_id"], name: "index_item_attachments_on_item_id"
  end

  create_table "item_pools", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "uniquely_numbered", default: true, null: false
    t.integer "reservable_items_count", default: 0, null: false
    t.integer "unnumbered_count"
    t.bigint "library_id", null: false
    t.text "description"
    t.text "other_names"
    t.text "plain_text_description"
    t.bigint "reservation_policy_id"
    t.string "checkout_notice"
    t.decimal "max_reservable_percent", precision: 2, scale: 2
    t.index ["creator_id"], name: "index_item_pools_on_creator_id"
    t.index ["library_id"], name: "index_item_pools_on_library_id"
    t.index ["reservation_policy_id"], name: "index_item_pools_on_reservation_policy_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "size"
    t.string "brand"
    t.string "model"
    t.string "serial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number", null: false
    t.enum "status", default: "active", null: false, enum_type: "item_status"
    t.bigint "borrow_policy_id", null: false
    t.string "strength"
    t.integer "quantity"
    t.string "checkout_notice"
    t.integer "holds_count", default: 0, null: false
    t.string "other_names"
    t.enum "power_source", enum_type: "power_source"
    t.text "location_area"
    t.text "location_shelf"
    t.integer "library_id"
    t.text "plain_text_description"
    t.string "url"
    t.string "purchase_link"
    t.integer "purchase_price_cents"
    t.string "myturn_item_type"
    t.boolean "holds_enabled", default: true
    t.index ["borrow_policy_id", "library_id"], name: "index_items_on_borrow_policy_id_and_library_id"
    t.index ["borrow_policy_id"], name: "index_items_on_borrow_policy_id"
    t.index ["library_id"], name: "index_items_on_library_id"
    t.index ["number", "library_id"], name: "index_items_on_number_and_library_id", unique: true
  end

  create_table "libraries", force: :cascade do |t|
    t.string "name", null: false
    t.string "hostname", null: false
    t.string "member_postal_code_pattern", limit: 100
    t.string "city", null: false
    t.string "email", null: false
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allow_members", default: true, null: false
    t.boolean "allow_payments", default: true, null: false
    t.boolean "allow_volunteers", default: true, null: false
    t.boolean "allow_appointments", default: true, null: false
    t.index ["hostname"], name: "index_libraries_on_hostname", unique: true
  end

  create_table "library_updates", force: :cascade do |t|
    t.string "title"
    t.boolean "published"
    t.bigint "library_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id", "published"], name: "index_library_updates_on_library_id_and_published"
    t.index ["library_id"], name: "index_library_updates_on_library_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "item_id"
    t.bigint "member_id"
    t.datetime "due_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "uniquely_numbered", null: false
    t.integer "renewal_count", default: 0, null: false
    t.bigint "initial_loan_id"
    t.integer "library_id"
    t.index ["ended_at", "library_id"], name: "index_loans_on_ended_at_and_library_id"
    t.index ["ended_at"], name: "index_loans_on_ended_at"
    t.index ["initial_loan_id", "library_id"], name: "index_loans_on_initial_loan_id_and_library_id"
    t.index ["initial_loan_id", "renewal_count", "library_id"], name: "index_loans_on_initial_loan_id_and_renewal_count_and_library_id", unique: true
    t.index ["initial_loan_id", "renewal_count"], name: "index_loans_on_initial_loan_id_and_renewal_count", unique: true
    t.index ["initial_loan_id"], name: "index_loans_on_initial_loan_id"
    t.index ["item_id", "library_id"], name: "index_active_numbered_loans_on_item_id_and_library_id", unique: true, where: "((ended_at IS NULL) AND (uniquely_numbered = true))"
    t.index ["item_id", "library_id"], name: "index_loans_on_item_id_and_library_id"
    t.index ["item_id"], name: "index_active_numbered_loans_on_item_id", unique: true, where: "((ended_at IS NULL) AND (uniquely_numbered = true))"
    t.index ["item_id"], name: "index_loans_on_item_id"
    t.index ["library_id"], name: "index_loans_on_library_id"
    t.index ["member_id", "library_id"], name: "index_loans_on_member_id_and_library_id"
    t.index ["member_id"], name: "index_loans_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "preferred_name"
    t.string "email", null: false
    t.string "phone_number", null: false
    t.text "bio"
    t.integer "id_kind"
    t.string "other_id_kind"
    t.boolean "address_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.string "postal_code"
    t.boolean "reminders_via_email", default: false, null: false
    t.boolean "reminders_via_text", default: false, null: false
    t.boolean "receive_newsletter", default: false, null: false
    t.boolean "volunteer_interest", default: false, null: false
    t.string "desires"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "region"
    t.integer "number"
    t.text "pronouns", default: [], array: true
    t.string "pronunciation"
    t.integer "library_id"
    t.bigint "user_id"
    t.index ["library_id", "number"], name: "index_members_on_library_id_and_number", unique: true
    t.index ["library_id", "user_id"], name: "index_members_on_library_id_and_user_id", unique: true
    t.index ["library_id"], name: "index_members_on_library_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.enum "membership_type", default: "initial", null: false, enum_type: "membership_type"
    t.index ["member_id"], name: "index_memberships_on_member_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "notable_type", null: false
    t.bigint "notable_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_notes_on_creator_id"
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "address", null: false
    t.string "action", null: false
    t.bigint "member_id"
    t.string "uuid", null: false
    t.string "status", default: "pending", null: false
    t.string "subject", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.index ["library_id"], name: "index_notifications_on_library_id"
    t.index ["member_id"], name: "index_notifications_on_member_id"
    t.index ["uuid"], name: "index_notifications_on_uuid"
  end

  create_table "organization_members", force: :cascade do |t|
    t.text "full_name"
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "member", null: false, enum_type: "organization_member_role"
    t.index ["organization_id", "user_id"], name: "index_organization_members_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_organization_members_on_organization_id"
    t.index ["user_id"], name: "index_organization_members_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.text "name", null: false
    t.text "website"
    t.bigint "library_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id", "name"], name: "index_organizations_on_library_id_and_name", unique: true
    t.index ["library_id", "website"], name: "index_organizations_on_library_id_and_website", unique: true
    t.index ["library_id"], name: "index_organizations_on_library_id"
  end

  create_table "pending_reservation_items", force: :cascade do |t|
    t.bigint "reservable_item_id", null: false
    t.bigint "reservation_id", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_pending_reservation_items_on_created_by_id"
    t.index ["reservable_item_id"], name: "index_pending_reservation_items_on_reservable_item_id", unique: true
    t.index ["reservation_id"], name: "index_pending_reservation_items_on_reservation_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "archived_at"
    t.bigint "library_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id"], name: "index_questions_on_library_id"
    t.index ["name"], name: "index_questions_on_name", unique: true
  end

  create_table "renewal_requests", force: :cascade do |t|
    t.enum "status", default: "requested", null: false, enum_type: "renewal_request_status"
    t.bigint "loan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.index ["library_id"], name: "index_renewal_requests_on_library_id"
    t.index ["loan_id"], name: "index_renewal_requests_on_loan_id"
  end

  create_table "reservable_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_pool_id", null: false
    t.bigint "creator_id", null: false
    t.bigint "library_id", null: false
    t.enum "status", enum_type: "item_status"
    t.string "brand"
    t.string "model"
    t.string "serial"
    t.integer "number", null: false
    t.integer "purchase_price_cents"
    t.string "size"
    t.string "strength"
    t.enum "power_source", enum_type: "power_source"
    t.string "location_area"
    t.string "location_shelf"
    t.string "purchase_link"
    t.string "url"
    t.jsonb "myturn_metadata", default: {}
    t.index ["creator_id"], name: "index_reservable_items_on_creator_id"
    t.index ["item_pool_id"], name: "index_reservable_items_on_item_pool_id"
    t.index ["library_id"], name: "index_reservable_items_on_library_id"
    t.index ["number", "library_id"], name: "index_reservable_items_on_number_and_library_id", unique: true
  end

  create_table "reservation_holds", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_pool_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "library_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.index ["item_pool_id", "reservation_id"], name: "index_reservation_holds_on_item_pool_id_and_reservation_id", unique: true
    t.index ["item_pool_id"], name: "index_reservation_holds_on_item_pool_id"
    t.index ["library_id"], name: "index_reservation_holds_on_library_id"
    t.index ["reservation_id"], name: "index_reservation_holds_on_reservation_id"
  end

  create_table "reservation_loans", force: :cascade do |t|
    t.bigint "reservation_hold_id", null: false
    t.bigint "reservable_item_id"
    t.integer "quantity", default: 1, null: false
    t.bigint "library_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "checked_out_at", precision: nil
    t.datetime "checked_in_at", precision: nil
    t.bigint "reservation_id", null: false
    t.index ["library_id"], name: "index_reservation_loans_on_library_id"
    t.index ["reservable_item_id", "reservation_hold_id"], name: "idx_on_reservable_item_id_reservation_hold_id_1dde83e836", unique: true
    t.index ["reservable_item_id"], name: "index_reservation_loans_on_reservable_item_id"
    t.index ["reservation_hold_id"], name: "index_reservation_loans_on_reservation_hold_id"
    t.index ["reservation_id"], name: "index_reservation_loans_on_reservation_id"
  end

  create_table "reservation_policies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "default", default: false, null: false
    t.integer "maximum_duration", default: 21, null: false
    t.integer "minimum_start_distance", default: 2, null: false
    t.integer "maximum_start_distance", default: 90, null: false
    t.bigint "library_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id", "name"], name: "index_reservation_policies_on_library_id_and_name", unique: true
    t.index ["library_id"], name: "index_reservation_policies_on_library_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.string "name"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "status", default: "pending", enum_type: "reservation_status"
    t.string "notes"
    t.datetime "reviewed_at"
    t.bigint "reviewer_id"
    t.bigint "library_id", null: false
    t.bigint "organization_id", null: false
    t.bigint "submitted_by_id", null: false
    t.bigint "pickup_event_id"
    t.bigint "dropoff_event_id"
    t.index ["dropoff_event_id"], name: "index_reservations_on_dropoff_event_id"
    t.index ["library_id"], name: "index_reservations_on_library_id"
    t.index ["organization_id"], name: "index_reservations_on_organization_id"
    t.index ["pickup_event_id"], name: "index_reservations_on_pickup_event_id"
    t.index ["reviewer_id"], name: "index_reservations_on_reviewer_id"
    t.index ["submitted_by_id"], name: "index_reservations_on_submitted_by_id"
  end

  create_table "stems", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.text "content", null: false
    t.enum "answer_type", default: "text", null: false, enum_type: "answer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_stems_on_question_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "ticket_updates", force: :cascade do |t|
    t.integer "time_spent"
    t.bigint "ticket_id", null: false
    t.bigint "creator_id", null: false
    t.bigint "audit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "library_id"
    t.index ["audit_id"], name: "index_ticket_updates_on_audit_id"
    t.index ["creator_id"], name: "index_ticket_updates_on_creator_id"
    t.index ["library_id"], name: "index_ticket_updates_on_library_id"
    t.index ["ticket_id"], name: "index_ticket_updates_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "item_id", null: false
    t.enum "status", default: "assess", null: false, enum_type: "ticket_status"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "library_id"
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["item_id"], name: "index_tickets_on_item_id"
    t.index ["library_id"], name: "index_tickets_on_library_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "member", null: false, enum_type: "user_role"
    t.integer "library_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index "lower((email)::text), library_id", name: "index_users_on_lowercase_email_and_library_id", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["library_id"], name: "index_users_on_library_id"
    t.index ["reset_password_token", "library_id"], name: "index_users_on_reset_password_token_and_library_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token", "library_id"], name: "index_users_on_unlock_token_and_library_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "adjustments", "members"
  add_foreign_key "agreement_acceptances", "members"
  add_foreign_key "answers", "reservations"
  add_foreign_key "answers", "stems"
  add_foreign_key "borrow_policy_approvals", "borrow_policies"
  add_foreign_key "borrow_policy_approvals", "members"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "gift_memberships", "memberships"
  add_foreign_key "holds", "items"
  add_foreign_key "holds", "loans"
  add_foreign_key "holds", "members"
  add_foreign_key "holds", "users", column: "creator_id"
  add_foreign_key "item_attachments", "items"
  add_foreign_key "item_attachments", "users", column: "creator_id"
  add_foreign_key "item_pools", "libraries"
  add_foreign_key "item_pools", "users", column: "creator_id"
  add_foreign_key "loans", "items"
  add_foreign_key "loans", "loans", column: "initial_loan_id"
  add_foreign_key "loans", "members"
  add_foreign_key "members", "users"
  add_foreign_key "memberships", "members"
  add_foreign_key "notes", "users", column: "creator_id"
  add_foreign_key "notifications", "members"
  add_foreign_key "organization_members", "organizations"
  add_foreign_key "organization_members", "users"
  add_foreign_key "organizations", "libraries"
  add_foreign_key "pending_reservation_items", "reservable_items"
  add_foreign_key "pending_reservation_items", "reservations"
  add_foreign_key "pending_reservation_items", "users", column: "created_by_id"
  add_foreign_key "renewal_requests", "loans"
  add_foreign_key "reservable_items", "item_pools"
  add_foreign_key "reservable_items", "libraries"
  add_foreign_key "reservable_items", "users", column: "creator_id"
  add_foreign_key "reservation_holds", "item_pools"
  add_foreign_key "reservation_holds", "libraries"
  add_foreign_key "reservation_loans", "libraries"
  add_foreign_key "reservation_loans", "reservable_items"
  add_foreign_key "reservation_loans", "reservation_holds"
  add_foreign_key "reservations", "events", column: "dropoff_event_id"
  add_foreign_key "reservations", "events", column: "pickup_event_id"
  add_foreign_key "reservations", "libraries"
  add_foreign_key "reservations", "users", column: "reviewer_id"
  add_foreign_key "reservations", "users", column: "submitted_by_id"
  add_foreign_key "stems", "questions"
  add_foreign_key "taggings", "tags"
  add_foreign_key "ticket_updates", "audits"
  add_foreign_key "ticket_updates", "tickets"
  add_foreign_key "ticket_updates", "users", column: "creator_id"
  add_foreign_key "tickets", "items"
  add_foreign_key "tickets", "users", column: "creator_id"

  create_view "category_nodes", materialized: true, sql_definition: <<-SQL
      WITH RECURSIVE search_tree(id, library_id, name, slug, parent_id, path_names, path_ids) AS (
           SELECT categories.id,
              categories.library_id,
              categories.name,
              categories.slug,
              categories.parent_id,
              ARRAY[categories.name] AS "array",
              ARRAY[categories.id] AS "array"
             FROM categories
            WHERE (categories.parent_id IS NULL)
          UNION ALL
           SELECT categories.id,
              categories.library_id,
              categories.name,
              categories.slug,
              categories.parent_id,
              (search_tree.path_names || categories.name),
              (search_tree.path_ids || categories.id)
             FROM (search_tree
               JOIN categories ON ((categories.parent_id = search_tree.id)))
            WHERE (NOT (categories.id = ANY (search_tree.path_ids)))
          ), tree_nodes AS (
           SELECT search_tree.id,
              search_tree.library_id,
              search_tree.name,
              search_tree.slug,
              search_tree.parent_id,
              search_tree.path_names,
              search_tree.path_ids,
              lower(array_to_string(search_tree.path_names, ' '::text)) AS sort_name,
              ( SELECT array_agg(st.id) AS array_agg
                     FROM search_tree st
                    WHERE (search_tree.id = ANY (st.path_ids))) AS tree_ids
             FROM search_tree
            ORDER BY (lower(array_to_string(search_tree.path_names, ' '::text)))
          )
   SELECT tree_nodes.id,
      tree_nodes.library_id,
      tree_nodes.name,
      tree_nodes.slug,
      tree_nodes.parent_id,
      tree_nodes.path_names,
      tree_nodes.path_ids,
      tree_nodes.sort_name,
      tree_nodes.tree_ids,
      ( SELECT json_build_object('active', count(DISTINCT categorizations.categorized_id) FILTER (WHERE (items.status = 'active'::item_status)), 'retired', count(DISTINCT categorizations.categorized_id) FILTER (WHERE (items.status = 'pending'::item_status)), 'maintenance', count(DISTINCT categorizations.categorized_id) FILTER (WHERE (items.status = 'maintenance'::item_status)), 'pending', count(DISTINCT categorizations.categorized_id) FILTER (WHERE (items.status = 'retired'::item_status))) AS json_build_object
             FROM (categorizations
               LEFT JOIN items ON ((categorizations.categorized_id = items.id)))
            WHERE (categorizations.category_id = ANY (tree_nodes.tree_ids))) AS tree_item_counts,
      ( SELECT json_build_object('active', count(DISTINCT reservable_items.id) FILTER (WHERE (reservable_items.status = 'active'::item_status)), 'retired', count(DISTINCT reservable_items.id) FILTER (WHERE (reservable_items.status = 'pending'::item_status)), 'maintenance', count(DISTINCT reservable_items.id) FILTER (WHERE (reservable_items.status = 'maintenance'::item_status)), 'pending', count(DISTINCT reservable_items.id) FILTER (WHERE (reservable_items.status = 'retired'::item_status))) AS json_build_object
             FROM ((categorizations
               LEFT JOIN item_pools ON (((categorizations.categorized_id = item_pools.id) AND (categorizations.categorized_type = 'ItemPool'::text))))
               LEFT JOIN reservable_items ON ((reservable_items.item_pool_id = item_pools.id)))
            WHERE (categorizations.category_id = ANY (tree_nodes.tree_ids))) AS tree_reservable_item_counts
     FROM tree_nodes;
  SQL
  add_index "category_nodes", ["id"], name: "index_category_nodes_on_id", unique: true

  create_view "loan_summaries", sql_definition: <<-SQL
      SELECT loans.library_id,
      loans.item_id,
      loans.member_id,
      COALESCE(loans.initial_loan_id, loans.id) AS initial_loan_id,
      max(loans.id) AS latest_loan_id,
      min(loans.created_at) AS created_at,
      max(loans.due_at) AS due_at,
          CASE
              WHEN (count(loans.ended_at) = count(loans.id)) THEN max(loans.ended_at)
              ELSE NULL::timestamp without time zone
          END AS ended_at,
      max(loans.renewal_count) AS renewal_count
     FROM loans
    GROUP BY loans.library_id, loans.item_id, loans.member_id, COALESCE(loans.initial_loan_id, loans.id);
  SQL
  create_view "monthly_adjustments", sql_definition: <<-SQL
      SELECT (date_part('year'::text, adjustments.created_at))::integer AS year,
      (date_part('month'::text, adjustments.created_at))::integer AS month,
      count(*) FILTER (WHERE ((adjustments.kind = 'membership'::adjustment_kind) AND (adjustments.adjustable_id = first_memberships.first_membership_id))) AS new_membership_count,
      sum((- adjustments.amount_cents)) FILTER (WHERE ((adjustments.kind = 'membership'::adjustment_kind) AND (adjustments.adjustable_id = first_memberships.first_membership_id))) AS new_membership_total_cents,
      count(*) FILTER (WHERE ((adjustments.kind = 'membership'::adjustment_kind) AND (adjustments.adjustable_id <> first_memberships.first_membership_id))) AS renewal_membership_count,
      sum((- adjustments.amount_cents)) FILTER (WHERE ((adjustments.kind = 'membership'::adjustment_kind) AND (adjustments.adjustable_id <> first_memberships.first_membership_id))) AS renewal_membership_total_cents,
      COALESCE(sum(adjustments.amount_cents) FILTER (WHERE (adjustments.kind = 'payment'::adjustment_kind)), (0)::bigint) AS payment_total_cents,
      COALESCE(sum(adjustments.amount_cents) FILTER (WHERE ((adjustments.kind = 'payment'::adjustment_kind) AND (adjustments.payment_source = 'square'::adjustment_source))), (0)::bigint) AS square_total_cents,
      COALESCE(sum(adjustments.amount_cents) FILTER (WHERE ((adjustments.kind = 'payment'::adjustment_kind) AND (adjustments.payment_source = 'cash'::adjustment_source))), (0)::bigint) AS cash_total_cents
     FROM (adjustments
       LEFT JOIN ( SELECT members.id AS member_id,
              min(memberships.id) AS first_membership_id
             FROM (members
               LEFT JOIN memberships ON ((members.id = memberships.member_id)))
            GROUP BY members.id) first_memberships ON ((first_memberships.member_id = adjustments.member_id)))
    GROUP BY ((date_part('year'::text, adjustments.created_at))::integer), ((date_part('month'::text, adjustments.created_at))::integer)
    ORDER BY ((date_part('year'::text, adjustments.created_at))::integer), ((date_part('month'::text, adjustments.created_at))::integer);
  SQL
  create_view "monthly_appointments", sql_definition: <<-SQL
      WITH dates AS (
           SELECT min(date_trunc('month'::text, appointments.starts_at)) AS startm,
              max(date_trunc('month'::text, appointments.starts_at)) AS endm
             FROM appointments
          ), months AS (
           SELECT generate_series(dates.startm, dates.endm, 'P1M'::interval) AS month
             FROM dates
          )
   SELECT (date_part('year'::text, months.month))::integer AS year,
      (date_part('month'::text, months.month))::integer AS month,
      count(DISTINCT a.id) AS appointments_count,
      count(DISTINCT a.id) FILTER (WHERE (a.completed_at IS NOT NULL)) AS completed_appointments_count
     FROM (months
       LEFT JOIN appointments a ON ((date_trunc('month'::text, a.starts_at) = months.month)))
    GROUP BY months.month
    ORDER BY months.month;
  SQL
  create_view "monthly_members", sql_definition: <<-SQL
      WITH dates AS (
           SELECT min(date_trunc('month'::text, members.created_at)) AS startm,
              max(date_trunc('month'::text, members.created_at)) AS endm
             FROM members
          ), months AS (
           SELECT generate_series(dates.startm, dates.endm, 'P1M'::interval) AS month
             FROM dates
          )
   SELECT (date_part('year'::text, months.month))::integer AS year,
      (date_part('month'::text, months.month))::integer AS month,
      count(DISTINCT m.id) FILTER (WHERE (m.status = 0)) AS pending_members_count,
      count(DISTINCT m.id) FILTER (WHERE (m.status = 1)) AS new_members_count
     FROM (months
       LEFT JOIN members m ON ((date_trunc('month'::text, m.created_at) = months.month)))
    GROUP BY months.month
    ORDER BY months.month;
  SQL
  create_view "monthly_renewals", sql_definition: <<-SQL
      WITH dates AS (
           SELECT min(date_trunc('month'::text, loans.created_at)) AS startm,
              max(date_trunc('month'::text, loans.created_at)) AS endm
             FROM loans
          ), months AS (
           SELECT generate_series(dates.startm, dates.endm, 'P1M'::interval) AS month
             FROM dates
          )
   SELECT (EXTRACT(year FROM months.month))::integer AS year,
      (EXTRACT(month FROM months.month))::integer AS month,
      count(DISTINCT l.id) AS renewals_count
     FROM (months
       LEFT JOIN loans l ON ((date_trunc('month'::text, l.created_at) = months.month)))
    WHERE (l.initial_loan_id IS NOT NULL)
    GROUP BY months.month
    ORDER BY months.month;
  SQL
  create_view "monthly_loans", sql_definition: <<-SQL
      WITH dates AS (
           SELECT min(date_trunc('month'::text, loans.created_at)) AS startm,
              max(date_trunc('month'::text, loans.created_at)) AS endm
             FROM loans
          ), months AS (
           SELECT generate_series(dates.startm, dates.endm, 'P1M'::interval) AS month
             FROM dates
          )
   SELECT (EXTRACT(year FROM months.month))::integer AS year,
      (EXTRACT(month FROM months.month))::integer AS month,
      count(DISTINCT l.id) AS loans_count,
      count(DISTINCT l.member_id) AS active_members_count
     FROM (months
       LEFT JOIN loans l ON ((date_trunc('month'::text, l.created_at) = months.month)))
    WHERE (l.initial_loan_id IS NULL)
    GROUP BY months.month
    ORDER BY months.month;
  SQL
end
