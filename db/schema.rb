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

ActiveRecord::Schema.define(version: 20140805221643) do

  create_table "blogs", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "blogs", ["slug"], name: "index_blogs_on_slug", unique: true
  add_index "blogs", ["user_id"], name: "index_blogs_on_user_id"

  create_table "posts", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.integer  "blog_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "posts", ["blog_id"], name: "index_posts_on_blog_id"
  add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

# Could not dump table "roles" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.text     "options"
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_blog_id"
    t.string   "password_reset_token"
    t.string   "slug"
  end

  add_index "users", ["current_blog_id"], name: "index_users_on_current_blog_id"
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token"
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true

end
