# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140622181052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: true do |t|
    t.integer  "tea_time_id"
    t.integer  "user_id"
    t.integer  "status",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reason"
  end

  create_table "cities", force: true do |t|
    t.string   "name"
    t.string   "city_code"
    t.text     "description"
    t.text     "tagline"
    t.integer  "brew_status",            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
    t.string   "header_bg_file_name"
    t.string   "header_bg_content_type"
    t.integer  "header_bg_file_size"
    t.datetime "header_bg_updated_at"
  end

  add_index "cities", ["city_code"], name: "city_code_idx", unique: true, using: :btree

  create_table "proxy_cities", force: true do |t|
    t.integer "city_id"
    t.integer "proxy_city_id"
  end

  add_index "proxy_cities", ["city_id", "proxy_city_id"], name: "index_proxy_cities_on_city_id_and_proxy_city_id", unique: true, using: :btree
  add_index "proxy_cities", ["proxy_city_id", "city_id"], name: "index_proxy_cities_on_proxy_city_id_and_city_id", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "tea_times", force: true do |t|
    t.datetime "start_time"
    t.float    "duration"
    t.integer  "followup_status", default: 0
    t.text     "location"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "summary"
    t.text     "story"
    t.text     "topics"
    t.text     "tagline"
    t.integer  "home_city_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
