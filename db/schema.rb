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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111219151230) do

  create_table "articles", :force => true do |t|
    t.string   "source"
    t.date     "pub_date"
    t.string   "byline"
    t.string   "headline"
    t.string   "page"
    t.string   "src_url"
    t.string   "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_pages"
    t.integer  "word_count"
    t.string   "src_url_md5"
  end

  add_index "articles", ["src_url_md5"], :name => "src_url_md5_index", :unique => true

end
