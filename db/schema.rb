# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200520140059) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "document_type"
    t.binary "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_bookmarks_on_document_id"
    t.index ["document_type", "document_id"], name: "index_bookmarks_on_document_type_and_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "coverage_map_locations", force: :cascade do |t|
    t.integer  "dc_coverage_id"
    t.decimal  "latitude",        precision: 10, scale: 6
    t.decimal  "longitude",       precision: 10, scale: 6
    t.string   "location_rpt"
    t.string   "geojson_ssim"
    t.string   "placename"
    t.datetime "geocode_attempt"
    t.datetime "verified",                                 default: '2020-05-20 14:08:40'
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
  end

  create_table "dc_contributors", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "contributor"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "dc_coverages", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "coverage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_creators", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "creator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_dates", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unprocessed_date"
    t.string "english_date"
  end

  create_table "dc_descriptions", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_formats", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_identifiers", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_languages", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_publishers", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_relations", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_rights", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "rights"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_sources", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_subjects", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_terms_extents", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "extent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_terms_is_part_ofs", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "is_part_of"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_terms_spacials", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "spacial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_titles", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_types", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "failed_inbox_images", force: :cascade do |t|
    t.string   "image"
    t.string   "school"
    t.string   "action"
    t.string   "error"
    t.datetime "failed_at"
    t.boolean  "current",    default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "failed_inbox_images", id: :serial, force: :cascade do |t|
    t.string "image"
    t.string "school"
    t.string "action"
    t.string "error"
    t.datetime "failed_at"
    t.boolean "current", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "image_process_trackers", force: :cascade do |t|
    t.integer "files_processed"
    t.integer "total_files"
    t.integer "status",          default: 0
  end

  create_table "osm_api_calls", force: :cascade do |t|
    t.string   "placename"
    t.string   "sanitized_placename"
    t.text     "request"
    t.text     "response"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["placename"], name: "index_osm_api_calls_on_placename", using: :btree
    t.index ["sanitized_placename"], name: "index_osm_api_calls_on_sanitized_placename", using: :btree
  end

  create_table "raw_records", force: :cascade do |t|
    t.integer  "repository_id"
    t.string   "original_record_url"
    t.string   "oai_identifier"
    t.string   "set_spec"
    t.string   "original_entry_date"
    t.text     "xml_metadata"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "record_type"
  end

  create_table "full_texts", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.text "transcription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "image_process_trackers", id: :serial, force: :cascade do |t|
    t.integer "files_processed"
    t.integer "total_files"
    t.integer "status", default: 0
  end

  create_table "raw_records", id: :serial, force: :cascade do |t|
    t.integer "repository_id"
    t.string "original_record_url"
    t.string "oai_identifier"
    t.string "set_spec"
    t.string "original_entry_date"
    t.text "xml_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "record_type"
  end

  create_table "record_dc_creator_tables", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.integer "dc_creator_id"
  end

  create_table "record_dc_subject_tables", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.integer "dc_subject_id"
  end

  create_table "record_dc_type_tables", id: :serial, force: :cascade do |t|
    t.integer "record_id"
    t.integer "dc_type_id"
  end

  create_table "records", id: :serial, force: :cascade do |t|
    t.integer "raw_record_id"
    t.string "oai_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "is_part_of"
    t.string "file_name"
    t.string "thumbnail"
    t.integer "collection_id"
    t.string "slug"
    t.index ["slug"], name: "index_records_on_slug", unique: true
  end

  create_table "repositories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "email"
    t.string "url"
    t.string "abbreviation"
    t.string "short_name"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.binary "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "spotlight_attachments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.string "uid"
    t.integer "exhibit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_blacklight_configurations", id: :serial, force: :cascade do |t|
    t.integer "exhibit_id"
    t.text "facet_fields"
    t.text "index_fields"
    t.text "search_fields"
    t.text "sort_fields"
    t.text "default_solr_params"
    t.text "show"
    t.text "index"
    t.integer "default_per_page"
    t.text "per_page"
    t.text "document_index_view_types"
    t.string "thumbnail_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spotlight_contact_emails", id: :serial, force: :cascade do |t|
    t.integer "exhibit_id"
    t.string "email", default: "", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_spotlight_contact_emails_on_confirmation_token", unique: true
    t.index ["email", "exhibit_id"], name: "index_spotlight_contact_emails_on_email_and_exhibit_id", unique: true
  end

  create_table "spacial_map_locations", force: :cascade do |t|
    t.integer  "dc_terms_spacial_id"
    t.decimal  "latitude",            precision: 10, scale: 6
    t.decimal  "longitude",           precision: 10, scale: 6
    t.string   "location_rpt"
    t.string   "geojson_ssim"
    t.string   "placename"
    t.datetime "geocode_attempt"
    t.datetime "verified",                                     default: '2020-05-20 14:08:39'
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
