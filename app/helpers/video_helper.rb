# coding:utf-8
require "digest/md5"

module VideoHelper

  @transcode_info_dir="#{Rails.root}/log/transcode"
  @default_pbs_dir="#{Rails.root}/log/torque"
  # use openPBS, e.g. torque, to transcode the video
  # generate a pbs job configuration file,
  # submit the pbs job to openPBS server
  # return the pbs job id and its status
  def self.transfer_by_pbs(transObj)
    cmd=get_cmd(transObj)
    pbs_job_filename=File.join(@default_pbs_dir, transObj.gsv_number+".pbs")

    pbs_cmd="#PBS -S /bin/bash
#PBS -d #{@transcode_info_dir}
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -N #{transObj.gsv_number}
#PBS -q #{$VTRANS_CONFIG['pbs_job_queue']}

export LD_LIBRARY_PATH=#{ENV['LD_LIBRARY_PATH']}

#{cmd} 2>&1
    "
    if !Dir.exist? @default_pbs_dir
      FileUtils.makedirs(@default_pbs_dir)
    end
    if !Dir.exist? @transcode_info_dir
      FileUtils.makedirs(@transcode_info_dir)
    end
    pbs_job_file=File.new(pbs_job_filename, 'w')
    pbs_job_file.write(pbs_cmd)
    pbs_job_file.close

    running_cmd="#!/bin/bash
qstat=" "
jobId=\`qsub  #{pbs_job_file.path}\`
if [ \"$?\" = \"0\" ]; then
  qstat=\`qstat ${jobId} 2>/dev/null | tail -n1 | awk \'{print $5}\'\`
fi

echo -e ${jobId}\";${qstat}\"
    "

    running_file=File.new(File.join(@default_pbs_dir, "_running_file"), 'w')
    running_file.write(running_cmd)
    running_file.close
    %x[chmod +x #{running_file.path}]
    #qsub #{pbs_job_file}
    pbs_job_info=%x[bash -c #{running_file.path}]
    arr=pbs_job_info.split(';')
    pbs_job_id=arr[0]
    pbs_job_stat=arr[1][0]

    if (pbs_job_stat == nil)
      raise Exception.new(error_info(:ERROR_003))
    end
    [pbs_job_id, pbs_job_stat]
  end

  # get the openPBS status
  # delete the error pbs job
  # get the information of successful pbs job
  # return job status
  def self.get_pbs_status(transObj)
    job_stat_info=%x[qstat -f #{transObj.pbs_job_id} 2>/dev/null]

    # job is running or queue or complete but not keep the id
    if (job_stat_info != "" && job_stat_info != nil)
      info_reg=%r{job_state = (\w)}.match(job_stat_info)
      job_stat=parse_status_from_pbs_stat(info_reg[1])
      if (job_stat==trans_status(:ERROR))
        %x[qdel #{transObj.pbs_job_id} 2>/dev/null]
      end
    end

    if ((job_stat)==trans_status(:COMPLETE) || job_stat_info == "" || job_stat_info == nil)
      gsv=transObj.gsv_number
      seq=transObj.pbs_job_id.split('.')[0]
      log_file="#{@transcode_info_dir}/#{gsv}.o#{seq}"
      log_lines=VideoHelper.get_log_info(log_file)

      if (log_lines=~%r{video:.*? audio:.*? subtitle:.*? global headers:.*? muxing overhead .*?})
        job_stat= trans_status(:COMPLETE)
        dest_path=File.join(transObj.path, transObj.filename+"."+transObj.video_format)
        v_info=VideoHelper.record_video_info(dest_path)
        if (job_stat_info!=nil && job_stat_info!="")
          info_reg=%r{resources_used.walltime = (\d+:\d+:\d+).*? comp_time = (.*?)\n}m.match(job_stat_info)
          v_info[:cost_time] = info_reg[1]
          v_info[:complete_time] = info_reg[2]
        end
        transObj.update_attributes!(v_info)
        transObj.save!
      else
        job_stat= trans_status(:ERROR)
      end
    end
    job_stat
  end

  def self.transfer_by_transObj(transObj)
    cmd=get_cmd(transObj)

    log_file="#{Rails.root}/log/upload/#{transObj.gsv_number}.log"
    stat=system "#{cmd} >#{log_file} 2>&1 &"

    if (!stat)
      raise Exception.new(error_info(:ERROR_003))
    end
    log_file
  end

  # read a log file
  # return the file content
  def self.get_log_info(log_path)
    if !File.exists?(log_path)
      raise Exception.new(error_info(:ERROR_002))
    end
    IO.read(log_path)
  end

  # use ffmpeg or other video software to get the video basic information
  # create the basic video information
  def self.get_video_info_by_path(file_path)
    begin
      video_extension=File.extname(file_path).downcase
      video_format=video_extension[1..-1]
      filename=File.basename(file_path, video_extension)
      VideoHelper.check_extension(video_extension)
      gsv_number= Digest::MD5.hexdigest(filename)

      v_info=VideoHelper.record_video_info(file_path)

      v_info[:path]= File.dirname(file_path)
      v_info[:video_format]=video_format
      v_info[:filename]=filename
      v_info[:gsv_number]=gsv_number
      v_info
    rescue => err
      raise err.Exception
    end
  end

  # use ffmpeg or other video software to get the video basic information
  # return the subset of basic information of one video
  def self.record_video_info(video_path)
    if (!File.exist?(video_path))
      raise Exception.new(error_info(:ERROR_002))
    end

    video_info=`#{$VTRANS_CONFIG['trans_cmd']} -i #{video_path} 2>&1`

    filename=File.basename(video_path)
    p video_info
    write_log_to_file(video_info, "#{Rails.root}/log/upload/#{filename}.log")
    if ($? != 0)
      msg=video_info.split("\n")[-1]
      if (msg !~ %r{At least one output file must be specified})
        raise Exception.new(msg)
      end
    end

    info_reg=%r{Duration: (.*?)\.\d*?, start: (.*?), bitrate: (\d*) kb\/s.*?Video: (\w+).*?, (.*?), (\w+).*?Audio: (\w+).*?, (\d+) Hz, (\w+).*}m.match(video_info)
    {:duration => info_reg[1],
     :vcodec => info_reg[4],
     :frame_size => info_reg[6],
     :acodec => info_reg[7],
     :data_size => File.new(video_path).size}
  end

  # check the video format is legal
  def self.check_extension(extension)
    file_reg=%r{\.(#{$VTRANS_CONFIG['allow_extension'].split(';').join('|')})}i
    if ((extension=~file_reg)==nil)
      raise Exception.new("extension #{extension} is not available!")
    end
  end

  # check the transcode parameters is legal
  def self.check_params(params)
    if (params[:filename]=="" && params[:filename]==nil)
      raise Exception.new(error_info(:ERROR_005)+" filename is empty!")
    end
    if (params[:path]=="" && params[:path]==nil)
      params[:path]=$VTRANS_CONFIG['trans_path']
    end
    if (params[:vcodec]=="" && params[:vcodec]==nil)
      raise Exception.new(error_info(:ERROR_005)+" video codec is null! ")
    end
    if (params[:acodec]=="" && params[:acodec]==nil)
      raise Exception.new(error_info(:ERROR_005)+" audio codec is null! ")
    end
    if (params[:frame_size]=="" && params[:frame_size]==nil)
      params[:frame_size]=""
    end
    if (params[:aspect]=="" && params[:aspect]==nil)
      params[:aspect]=""
    end
    if (params[:frame_rate]=="" && params[:frame_rate]==nil)
      params[:frame_rate]=0.0
    end
    if (params[:video_bitrate]=="" && params[:video_bitrate]==nil)
      params[:video_bitrate]=0
    end
    if (params[:audio_bitrate]=="" && params[:audio_bitrate]==nil)
      params[:audio_bitrate]=0
    end
    if (params[:audio_sample_rate]=="" && params[:audio_sample_rate]==nil)
      params[:audio_sample_rate]=0
    end
    if (params[:audio_channel]=="" && params[:audio_channel]==nil)
      params[:audio_channel]=0
    end

    params
  end

  private

  def self.get_cmd(transObj)
    if (!transObj.is_a?(Transcode))
      raise Exception.new(error_info(:ERROR_001))
    end
    origObj=transObj.video_source
    src_path=File.join(origObj.path, origObj.filename+"."+origObj.video_format)
    dest_path=File.join(transObj.path, transObj.filename+"."+transObj.video_format)
    src_path=File.join(Rails.root, src_path) if Pathname.new(src_path).relative?
    dest_path=File.join(Rails.root, dest_path) if Pathname.new(dest_path).relative?

    if (!File.exist? src_path)
      raise Exception.new(error_info(:ERROR_002))
    end
    #if (File.exist? dest_path)
    #  raise Exception.new(error_info(:ERROR_004))
    #end

    src_dir=File.dirname(src_path)
    if (!Dir.exist? src_dir)
      FileUtils.makedirs(src_dir)
    end

    dest_dir=File.dirname(dest_path)
    if (!Dir.exist? dest_dir)
      FileUtils.makedirs(dest_dir)
    end

    cmd1= " -c:v #{transObj.vcodec} "
    if (transObj.video_bitrate!=0 && transObj.video_bitrate!=nil)
      cmd1+=" -b:v #{transObj.video_bitrate}k "
    end
    if (transObj.frame_rate!=0.0 && transObj.frame_rate!=nil)
      cmd1+=" -r #{transObj.frame_rate} "
    end
    if (transObj.frame_size!="" && transObj.frame_size!=nil)
      cmd1+=" -s #{transObj.frame_size} "
    end
    if (transObj.aspect!="" && transObj.aspect!=nil)
      cmd1+=" -aspect #{transObj.aspect} "
    end
    cmd1+= " -c:a #{transObj.acodec} "
    if (transObj.audio_bitrate!=0 && transObj.audio_bitrate!=nil)
      cmd1+=" -ab #{transObj.audio_bitrate}k "
    end
    if (transObj.audio_sample_rate!=0 && transObj.audio_sample_rate!=nil)
      cmd1+=" -ar #{transObj.audio_sample_rate} "
    end
    if (transObj.audio_channel!=0 && transObj.audio_channel!=nil)
      cmd1+=" -ac #{transObj.audio_channel} "
    end

    if (transObj.video_format!=0 && transObj.video_format!=nil)
      if (transObj.video_format=="mpg")
        cmd1+=" -f mpeg "
      elsif (transObj.video_format=="mkv")
        cmd1+=" -f matroska "
      else
        cmd1+=" -f #{transObj.video_format} "
      end
    end

    "#{$VTRANS_CONFIG['trans_cmd']} -i #{src_path} #{cmd1} -y #{dest_path}"
  end

  def self.write_log_to_file(msg, log_path)

    log_dir=File.dirname(log_path)
    if !File.exists?(log_dir)
      FileUtils.makedirs(log_dir)
    end
    info_file=File.new(log_path, "w")
    info_file.puts(msg)
    info_file.close
  end

  def self.error_info (error_type)
    error_list = {
        :ERROR_001 => '未知错误',
        :ERROR_002 => '文件不存在',
        :ERROR_003 => '转码错误',
        :ERROR_004 => '文件已存在',
        :ERROR_005 => '转码参数错误',
        :ERROR_006 => '类型错误',
        :ERROR_007 => '没有记录'
    }

    return error_list[error_type]
  end


  def self.trans_status (type)
    status_list={
        :PREPARE => "准备",
        :QUEUE => "等待",
        :RUNNING => "运行",
        :COMPLETE => "完成",
        :ERROR => "出错"
    }

    status_list[type]
  end

  def self.parse_status_from_pbs_stat(param)
    case param
      when "C"
        trans_status(:COMPLETE)
      when "E"
        trans_status(:RUNNING)
      when "H"
        trans_status(:ERROR)
      when "Q"
        trans_status(:QUEUE)
      when "R"
        trans_status(:RUNNING)
      when "T"
        trans_status(:ERROR)
      when "W"
        trans_status(:ERROR)
      when "S"
        trans_status(:ERROR)
    end
  end

end
