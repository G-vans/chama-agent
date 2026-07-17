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

ActiveRecord::Schema[8.1].define(version: 2026_07_17_144755) do
  create_table "agent_reports", force: :cascade do |t|
    t.integer "chama_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.datetime "updated_at", null: false
    t.index ["chama_id"], name: "index_agent_reports_on_chama_id"
  end

  create_table "chamas", force: :cascade do |t|
    t.decimal "contibution_amount"
    t.datetime "created_at", null: false
    t.string "frequency"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "mpesa_receipt"
    t.datetime "paid_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_contributions_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "chama_id", null: false
    t.datetime "created_at", null: false
    t.date "joined_at"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["chama_id"], name: "index_members_on_chama_id"
  end

  add_foreign_key "agent_reports", "chamas"
  add_foreign_key "contributions", "members"
  add_foreign_key "members", "chamas"
end
