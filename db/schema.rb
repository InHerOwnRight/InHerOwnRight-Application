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

ActiveRecord::Schema.define(version: 20170328193534) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "document_type"
    t.binary   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["document_id"], name: "index_bookmarks_on_document_id", using: :btree
    t.index ["user_id"], name: "index_bookmarks_on_user_id", using: :btree
  end

  create_table "dc_contributors", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "contributor"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "dc_creators", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "creator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_descriptions", force: :cascade do |t|
    t.integer  "record_id"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "dc_publishers", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_subjects", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dc_titles", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "records", force: :cascade do |t|
    t.integer  "raw_record_id"
    t.string   "oai_identifier"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "searches", force: :cascade do |t|
    t.binary   "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_searches_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
