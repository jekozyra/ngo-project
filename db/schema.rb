# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100519050320) do

  create_table "affiliations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "affiliations_ngos", :id => false, :force => true do |t|
    t.integer "ngo_id"
    t.integer "affiliation_id"
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "latlong"
    t.string   "iso_code"
  end

  create_table "ngos", :force => true do |t|
    t.string   "acronym"
    t.string   "name"
    t.integer  "country_id"
    t.integer  "district_id"
    t.string   "contact_name"
    t.string   "contact_position"
    t.string   "contact_address"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.boolean  "auto_update",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ngos_sectors", :id => false, :force => true do |t|
    t.integer "ngo_id"
    t.integer "sector_id"
  end

  create_table "sectors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "user_type"
    t.boolean  "approved",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
