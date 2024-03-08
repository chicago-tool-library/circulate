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

ActiveRecord::Schema[7.1].define(version: 2024_03_03_164619) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_enum :hold_request_status, [
    "new",
    "completed",
    "denied",
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
  ], force: :cascade

  create_enum :pickup_status, [
    "building",
    "ready_for_pickup",
    "picked_up",
    "cancelled",
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
  ], force: :cascade

  create_enum :ticket_status, [
    "assess",
    "parts",
    "repairing",
    "resolved",
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
    t.index ["library_id", "name"], name: "index_borrow_policies_on_library_id_and_name", unique: true
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
    t.bigint "item_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["item_id", "category_id"], name: "index_categorizations_on_item_id_and_category_id"
    t.index ["item_id"], name: "index_categorizations_on_item_id"
  end

  create_table "date_holds", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_pool_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "library_id", null: false
    t.index ["item_pool_id"], name: "index_date_holds_on_item_pool_id"
    t.index ["library_id"], name: "index_date_holds_on_library_id"
    t.index ["reservation_id"], name: "index_date_holds_on_reservation_id"
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
    t.integer "library_id"
    t.jsonb "attendees"
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

  create_table "holds", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "item_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at", precision: nil
    t.bigint "loan_id"
    t.integer "library_id"
    t.datetime "started_at", precision: nil
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
    t.index ["creator_id"], name: "index_item_pools_on_creator_id"
    t.index ["library_id"], name: "index_item_pools_on_library_id"
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
    t.integer "library_id"
    t.enum "power_source", enum_type: "power_source"
    t.text "location_area"
    t.text "location_shelf"
    t.text "plain_text_description"
    t.string "url"
    t.string "purchase_link"
    t.integer "purchase_price_cents"
    t.string "myturn_item_type"
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
    t.integer "library_id"
    t.string "pronunciation"
    t.index ["library_id"], name: "index_members_on_library_id"
    t.index ["number", "library_id"], name: "index_members_on_number_and_library_id"
    t.index ["number"], name: "index_members_on_number", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
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

  create_table "pickups", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.enum "status", default: "building", null: false, enum_type: "pickup_status"
    t.bigint "reservation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "library_id", null: false
    t.index ["creator_id"], name: "index_pickups_on_creator_id"
    t.index ["library_id"], name: "index_pickups_on_library_id"
    t.index ["reservation_id"], name: "index_pickups_on_reservation_id"
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
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_pool_id", null: false
    t.bigint "creator_id", null: false
    t.bigint "library_id", null: false
    t.index ["creator_id"], name: "index_reservable_items_on_creator_id"
    t.index ["item_pool_id"], name: "index_reservable_items_on_item_pool_id"
    t.index ["library_id"], name: "index_reservable_items_on_library_id"
  end

  create_table "reservation_loans", force: :cascade do |t|
    t.bigint "pickup_id", null: false
    t.bigint "date_hold_id", null: false
    t.bigint "reservable_item_id"
    t.integer "quantity", comment: "For item pools without uniquely numbered items"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_hold_id"], name: "index_reservation_loans_on_date_hold_id"
    t.index ["pickup_id"], name: "index_reservation_loans_on_pickup_id"
    t.index ["reservable_item_id"], name: "index_reservation_loans_on_reservable_item_id"
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
    t.index ["library_id"], name: "index_reservations_on_library_id"
    t.index ["reviewer_id"], name: "index_reservations_on_reviewer_id"
  end

  create_table "short_links", force: :cascade do |t|
    t.string "url", null: false
    t.string "slug", null: false
    t.integer "views_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.index ["library_id", "slug"], name: "index_short_links_on_library_id_and_slug"
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
    t.bigint "member_id"
    t.integer "library_id"
    t.index ["email", "library_id"], name: "index_users_on_email_and_library_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["library_id"], name: "index_users_on_library_id"
    t.index ["member_id", "library_id"], name: "index_users_on_member_id_and_library_id"
    t.index ["member_id"], name: "index_users_on_member_id"
    t.index ["reset_password_token", "library_id"], name: "index_users_on_reset_password_token_and_library_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token", "library_id"], name: "index_users_on_unlock_token_and_library_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "adjustments", "members"
  add_foreign_key "agreement_acceptances", "members"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "items"
  add_foreign_key "date_holds", "item_pools"
  add_foreign_key "date_holds", "libraries"
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
  add_foreign_key "memberships", "members"
  add_foreign_key "notes", "users", column: "creator_id"
  add_foreign_key "notifications", "members"
  add_foreign_key "pickups", "libraries"
  add_foreign_key "pickups", "reservations"
  add_foreign_key "pickups", "users", column: "creator_id"
  add_foreign_key "renewal_requests", "loans"
  add_foreign_key "reservable_items", "item_pools"
  add_foreign_key "reservable_items", "libraries"
  add_foreign_key "reservable_items", "users", column: "creator_id"
  add_foreign_key "reservation_loans", "date_holds"
  add_foreign_key "reservation_loans", "pickups"
  add_foreign_key "reservation_loans", "reservable_items"
  add_foreign_key "reservations", "libraries"
  add_foreign_key "reservations", "users", column: "reviewer_id"
  add_foreign_key "ticket_updates", "audits"
  add_foreign_key "ticket_updates", "tickets"
  add_foreign_key "ticket_updates", "users", column: "creator_id"
  add_foreign_key "tickets", "items"
  add_foreign_key "tickets", "users", column: "creator_id"
  add_foreign_key "users", "members"

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
      SELECT (EXTRACT(year FROM adjustments.created_at))::integer AS year,
      (EXTRACT(month FROM adjustments.created_at))::integer AS month,
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
    GROUP BY ((EXTRACT(year FROM adjustments.created_at))::integer), ((EXTRACT(month FROM adjustments.created_at))::integer)
    ORDER BY ((EXTRACT(year FROM adjustments.created_at))::integer), ((EXTRACT(month FROM adjustments.created_at))::integer);
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
   SELECT (EXTRACT(year FROM months.month))::integer AS year,
      (EXTRACT(month FROM months.month))::integer AS month,
      count(DISTINCT m.id) FILTER (WHERE (m.status = 0)) AS pending_members_count,
      count(DISTINCT m.id) FILTER (WHERE (m.status = 1)) AS new_members_count
     FROM (months
       LEFT JOIN members m ON ((date_trunc('month'::text, m.created_at) = months.month)))
    GROUP BY months.month
    ORDER BY months.month;
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
   SELECT (EXTRACT(year FROM months.month))::integer AS year,
      (EXTRACT(month FROM months.month))::integer AS month,
      count(DISTINCT a.id) AS appointments_count,
      count(DISTINCT a.id) FILTER (WHERE (a.completed_at IS NOT NULL)) AS completed_appointments_count
     FROM (months
       LEFT JOIN appointments a ON ((date_trunc('month'::text, a.starts_at) = months.month)))
    GROUP BY months.month
    ORDER BY months.month;
  SQL
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
      ( SELECT json_build_object('active', count(DISTINCT categorizations.item_id) FILTER (WHERE (items.status = 'active'::item_status)), 'retired', count(DISTINCT categorizations.item_id) FILTER (WHERE (items.status = 'pending'::item_status)), 'maintenance', count(DISTINCT categorizations.item_id) FILTER (WHERE (items.status = 'maintenance'::item_status)), 'pending', count(DISTINCT categorizations.item_id) FILTER (WHERE (items.status = 'retired'::item_status))) AS json_build_object
             FROM (categorizations
               LEFT JOIN items ON ((categorizations.item_id = items.id)))
            WHERE (categorizations.category_id = ANY (tree_nodes.tree_ids))) AS tree_item_counts
     FROM tree_nodes;
  SQL
  add_index "category_nodes", ["id"], name: "index_category_nodes_on_id", unique: true

end
