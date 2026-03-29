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

ActiveRecord::Schema[8.1].define(version: 2026_03_29_000742) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "field_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "field_id", null: false
    t.string "memo"
    t.string "status", default: "good", null: false
    t.string "tags", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["field_id"], name: "index_field_logs_on_field_id"
    t.index ["user_id"], name: "index_field_logs_on_user_id"
  end

  create_table "fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "crop"
    t.bigint "group_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_fields_on_group_id"
  end

  create_table "group_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_group_members_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_members_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_members_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invite_token", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_token"], name: "index_groups_on_invite_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", default: "", null: false
    t.string "name", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "field_logs", "fields"
  add_foreign_key "field_logs", "users"
  add_foreign_key "fields", "groups"
  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "users"
end
