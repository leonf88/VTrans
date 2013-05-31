# coding: utf-8
class Upload < ActiveRecord::Base
  attr_accessible :user_id, :filename, :gsv_number, :path, :video_format, :frame_size, :duration,
                  :vcodec, :acodec, :data_size, :created_at, :id

  validates_length_of :filename, :maximum => 50
  validates_length_of :gsv_number, :maximum => 40
  validates_length_of :path, :maximum => 80
  validates_length_of :video_format, :maximum => 5
  validates_length_of :frame_size, :maximum => 10
  validates_length_of :duration, :maximum => 10
  validates_length_of :vcodec, :maximum => 15
  validates_length_of :acodec, :maximum => 15

  validates_numericality_of :data_size
  validates_presence_of :filename, :gsv_number, :message => "不能为空"

  belongs_to :user
end
