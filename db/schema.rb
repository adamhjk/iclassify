# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 11) do

  create_table "attribs", :force => true do |t|
    t.integer "node_id",                 :null => false
    t.string  "name",    :default => "", :null => false
  end

  create_table "avalues", :force => true do |t|
    t.integer "attrib_id",                 :null => false
    t.text    "value",     :default => "", :null => false
  end

  create_table "nodes", :force => true do |t|
    t.string  "uuid",             :limit => 38, :default => "",    :null => false
    t.string  "description"
    t.text    "notes"
    t.string  "crypted_password", :limit => 40
    t.string  "salt",             :limit => 40
    t.boolean "quarantined",                    :default => false
  end

  create_table "nodes_tags", :id => false, :force => true do |t|
    t.integer "node_id", :null => false
    t.integer "tag_id",  :null => false
  end

  add_index "nodes_tags", ["node_id"], :name => "index_nodes_tags_on_node_id"
  add_index "nodes_tags", ["tag_id"], :name => "index_nodes_tags_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "readwrite",                               :default => true
  end

end
