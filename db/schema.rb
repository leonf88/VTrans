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

ActiveRecord::Schema.define(:version => 20121127123308) do

  create_table "transcodes", :force => true do |t|
    t.string   "filename",          :limit => 50
    t.string   "gsv_number",        :limit => 32,                                               :null => false
    t.string   "path",              :limit => 80
    t.string   "video_format",      :limit => 5
    t.string   "frame_size",        :limit => 10
    t.string   "duration",          :limit => 10
    t.string   "vcodec",            :limit => 15
    t.string   "acodec",            :limit => 15
    t.integer  "data_size"
    t.string   "aspect",            :limit => 15
    t.decimal  "frame_rate",                      :precision => 10, :scale => 0, :default => 0
    t.integer  "video_bitrate",                                                  :default => 0
    t.integer  "audio_sample_rate",                                              :default => 0
    t.integer  "audio_channel",                                                  :default => 0
    t.integer  "audio_bitrate",                                                  :default => 0
    t.datetime "complete_time"
    t.integer  "cost_time"
    t.string   "status",            :limit => 10,                                               :null => false
    t.string   "pbs_job_id",        :limit => 50
    t.integer  "user_id"
    t.integer  "video_source_id"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
  end

  add_index "transcodes", ["user_id"], :name => "fk_transcode_user"

  create_table "uploads", :force => true do |t|
    t.string   "filename",     :limit => 50, :null => false
    t.string   "gsv_number",   :limit => 40, :null => false
    t.string   "path",         :limit => 80, :null => false
    t.string   "video_format", :limit => 5
    t.string   "frame_size",   :limit => 10
    t.string   "duration",     :limit => 10
    t.string   "vcodec",       :limit => 15
    t.string   "acodec",       :limit => 15
    t.integer  "data_size"
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "uploads", ["user_id"], :name => "fk_upload_user"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "video_sources", :force => true do |t|
    t.string   "filename",     :limit => 50, :null => false
    t.string   "gsv_number",   :limit => 32, :null => false
    t.string   "path",         :limit => 80, :null => false
    t.string   "video_format", :limit => 5
    t.string   "frame_size",   :limit => 10
    t.string   "duration",     :limit => 10
    t.string   "vcodec",       :limit => 15
    t.string   "acodec",       :limit => 15
    t.integer  "data_size"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

end
