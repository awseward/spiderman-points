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

ActiveRecord::Schema.define(version: 2020_04_22_045222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "oauth_credentials", force: :cascade do |t|
    t.string "app_id", null: false
    t.string "team_id", null: false
    t.string "access_token", null: false
    t.string "scope", null: false
    t.string "bot_user_id", null: false
    t.string "authed_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "app_id"], name: "no_duplicate_credentials", unique: true
  end

  create_table "points", force: :cascade do |t|
    t.string "team_id", null: false
    t.string "from_id", null: false
    t.string "to_id", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "self_awarded_points", id: :serial, force: :cascade do |t|
    t.text "team_id", null: false
    t.text "user_id", null: false
    t.text "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "team_id", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "opted_out", default: false, null: false
    t.index ["team_id", "user_id"], name: "no_duplicate_users", unique: true
  end

end
