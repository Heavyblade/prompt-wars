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

ActiveRecord::Schema[8.0].define(version: 2025_09_07_123400) do
  create_table "approvals", force: :cascade do |t|
    t.integer "time_off_request_id", null: false
    t.integer "approver_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_approvals_on_approver_id"
    t.index ["time_off_request_id"], name: "index_approvals_on_time_off_request_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.integer "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_departments_on_manager_id"
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "time_off_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "time_off_type_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "reason"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_off_type_id"], name: "index_time_off_requests_on_time_off_type_id"
    t.index ["user_id", "start_date", "end_date"], name: "index_time_off_requests_on_user_id_and_start_date_and_end_date"
    t.index ["user_id"], name: "index_time_off_requests_on_user_id"
  end

  create_table "time_off_types", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_time_off_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.integer "department_id"
    t.integer "manager_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "role", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "approvals", "time_off_requests"
  add_foreign_key "approvals", "users", column: "approver_id"
  add_foreign_key "departments", "users", column: "manager_id"
  add_foreign_key "time_off_requests", "time_off_types"
  add_foreign_key "time_off_requests", "users"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "users", column: "manager_id"
end
