class VideoItem < ActiveRecord::Base
  attr_accessible :filename, :gsv_number, :path, :video_format, :frame_size,
                  :duration, :vcodec, :acodec, :data_size
end
