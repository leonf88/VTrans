class VideoSource < ActiveRecord::Base
  attr_accessible :id, :filename, :gsv_number, :path, :video_format, :frame_size,
                  :duration, :vcodec, :acodec, :data_size

  has_many :transcodes
end
