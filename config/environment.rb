# Load the rails application
require File.expand_path('../application', __FILE__)

#$default_pbs_job_queue='long'
#$upload_video_info_path=File.join(Rails.root, "log", "upload")
#$download_video_info_path=File.join(Rails.root, "log", "download")
#$transcode_video_info_path=File.join(Rails.root, "log", "transcode")
#$default_pbs_path=File.join(Rails.root, "log", "torque")
#$default_transcode_file_path="/mnt/glusterfs/transcode"
#$default_upload_file_path="/mnt/glusterfs/upload"
#$default_server_path="/mnt/glusterfs"
#
#$allow_video_extensions="mp4;3gp;flv;mpg"
#$fileDesc="File(*.mp4;*.3pg;*.mpg*;*.flv)"
#$max_file_size="512MB"
#$transcode_cmd="/usr/local/bin/ffmpeg"
$VTRANS_CONFIG = YAML.load_file("#{Rails.root}/config/vtrans.yml")

# Initialize the rails application
VTrans::Application.initialize!
