class Transcode < ActiveRecord::Base

  attr_accessible :user_id, :filename, :gsv_number, :path, :video_format, :frame_size, :duration,
                  :vcodec, :acodec, :data_size, :complete_time, :cost_time, :status, :video_source_id,
                  :aspect, :frame_rate, :video_bitrate, :audio_sample_rate, :audio_channel, :audio_bitrate,
                  :pbs_job_id

  validates_length_of :filename, :maximum => 50
  validates_length_of :gsv_number, :maximum => 40
  validates_length_of :path, :maximum => 80
  validates_length_of :video_format, :maximum => 5
  validates_length_of :frame_size, :maximum => 10
  validates_length_of :duration, :maximum => 10
  validates_length_of :vcodec, :maximum => 15
  validates_length_of :acodec, :maximum => 15
  validates_length_of :acodec, :maximum => 10
  validates_length_of :pbs_job_id, :maximum => 20

  validates_presence_of :filename, :gsv_number, :status, :message => "不能为空"

  belongs_to :video_source

end
