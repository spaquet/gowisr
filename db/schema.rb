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

ActiveRecord::Schema[8.0].define(version: 2025_04_29_003437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["locale"], name: "index_users_on_locale"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["stytch_user_id"], name: "index_users_on_stytch_user_id", unique: true
    t.index ["time_zone"], name: "index_users_on_time_zone"
    t.index ["use_gravatar"], name: "index_users_on_use_gravatar"
    t.index ["username"], name: "index_users_on_username", unique: true
  end
end
