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

ActiveRecord::Schema[8.0].define(version: 2025_04_29_051812) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.uuid "user_id", null: false
    t.uuid "llm_provider_id", null: false
    t.jsonb "settings", default: {}
    t.string "status", default: "active"
    t.datetime "last_activity_at"
    t.boolean "thinking_enabled", default: false
    t.boolean "is_favorite", default: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_provider_id"], name: "index_chats_on_llm_provider_id"
    t.index ["token"], name: "index_chats_on_token", unique: true
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "llm_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "provider_type", null: false
    t.string "llm_model_name", null: false
    t.jsonb "default_parameters", default: {}
    t.text "description"
    t.boolean "supports_thinking", default: false
    t.boolean "supports_files", default: false
    t.integer "token_limit"
    t.boolean "active", default: true
    t.integer "max_file_size_mb", default: 10
    t.integer "max_files", default: 5
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_type", "llm_model_name"], name: "index_llm_providers_on_provider_type_and_llm_model_name", unique: true
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_id", null: false
    t.uuid "user_id"
    t.text "content"
    t.string "role"
    t.jsonb "metadata", default: {}
    t.float "tokens_used"
    t.boolean "is_thinking", default: false
    t.string "status", default: "complete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "stytch_user_id"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "username"
    t.string "avatar_url"
    t.boolean "use_gravatar", default: true
    t.string "provider"
    t.string "uid"
    t.datetime "last_sign_in_at"
    t.string "time_zone"
    t.string "locale", default: "en"
    t.boolean "is_active", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["stytch_user_id"], name: "index_users_on_stytch_user_id", unique: true
    t.index ["time_zone"], name: "index_users_on_time_zone"
    t.index ["use_gravatar"], name: "index_users_on_use_gravatar"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "llm_providers"
  add_foreign_key "chats", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "users"
end
