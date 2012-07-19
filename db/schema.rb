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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120719191428) do

  create_table "answers", :force => true do |t|
    t.float    "confidence"
    t.integer  "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "judgements"
    t.integer  "article_id"
    t.string   "source",      :default => "CrowdFlower"
    t.integer  "user_id",                                :null => false
    t.integer  "question_id"
  end

  add_index "answers", ["article_id"], :name => "index_answers_on_article_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "articles", :force => true do |t|
    t.string   "source"
    t.date     "pub_date"
    t.string   "byline",              :limit => 500
    t.string   "headline",            :limit => 500
    t.string   "page"
    t.string   "src_url",             :limit => 1000
    t.string   "abstract",            :limit => 2000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_pages"
    t.integer  "word_count"
    t.string   "src_url_md5"
    t.string   "section"
    t.string   "queue_status"
    t.string   "scan_src_url",        :limit => 1000
    t.string   "scan_local_filename"
    t.string   "scan_file_url",       :limit => 1000
    t.string   "blacklist_tag"
    t.boolean  "golden",                              :default => false
    t.string   "sampletag"
    t.string   "gender",              :limit => 1
    t.float    "gender_prob"
  end

  add_index "articles", ["headline"], :name => "headline_fulltext_index"
  add_index "articles", ["queue_status"], :name => "index_articles_on_queue_status"
  add_index "articles", ["sampletag"], :name => "index_articles_on_sampletag"
  add_index "articles", ["source"], :name => "source_index"
  add_index "articles", ["src_url_md5"], :name => "src_url_md5_index", :unique => true

  create_table "golds", :force => true do |t|
    t.integer  "article_id"
    t.integer  "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reason",      :limit => 1000
    t.integer  "question_id"
  end

  add_index "golds", ["article_id"], :name => "index_golds_on_article_id"

  create_table "questions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "answer_one"
    t.text     "answer_two"
    t.text     "answer_three"
    t.text     "answer_four"
    t.text     "answer_five"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
