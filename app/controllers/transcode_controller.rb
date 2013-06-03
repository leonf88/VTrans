# coding: utf-8
class TranscodeController < ApplicationController
  layout 'basic'
  include ActionController::RequestForgeryProtection
  before_filter :authenticate_user!

  def index
    session[:authenticity_token]=form_authenticity_token
    respond_to do |format|
      format.html
    end
  end

  def create
    user_id=current_user.id.to_s
    info={}

    params[:data].each_pair do |key, val|
      begin
        if (params[:type]=="0")
          # data from upload
          if (!File.exist?(File.join(val[:path], val[:filename]+"."+val[:video_format])))
            raise Exception.new("File #{val[:filename]} doesn't exist!")
          end
          v=VideoSource.where(:gsv_number => val[:gsv_number]).first_or_create(:filename => val[:filename],
                                                                               :gsv_number => val[:gsv_number],
                                                                               :path => val[:path],
                                                                               :video_format => val[:video_format],
                                                                               :frame_size => val[:frame_size],
                                                                               :duration => val[:duration],
                                                                               :vcodec => val[:vcodec],
                                                                               :acodec => val[:acodec],
                                                                               :data_size => val[:data_size])
        elsif (params[:type]=="1")
          file_path=val
          # data from remote filesystem
          if (!File.exist?(File.join(file_path)))
            raise Exception.new("File #{file_path} doesn't exist!")
          end
          v_info=VideoHelper.get_video_info_by_path(file_path)
          v=VideoSource.where(:filename => v_info[:filename],
                              :path => v_info[:path],
                              :video_format => v_info[:video_format]).first_or_create(v_info)
        else
          raise Exception.new(VideoHelper.error_info(:ERROR_001))
        end

        dest_filename="trans-"+v.filename
        while (Transcode.find_all_by_filename(dest_filename).length!=0)
          dest_filename="trans-"+Digest::MD5.hexdigest(Time.new().to_s)[0, 5]+"-"+v.filename
        end
        trans=Transcode.create(:filename => dest_filename,
                               :duration => v[:duration],
                               :gsv_number => Digest::MD5.hexdigest(Time.new().to_s),
                               :status => VideoHelper.trans_status(:PREPARE),
                               :video_source_id => v.id,
                               :user_id => user_id)
        info[key]={:flag => true, :vsrc => v,
                   :vtar => {:id => trans.id, :gsv => trans.gsv_number, :status => trans.status, :filename => trans.filename}}
      rescue Exception => err
        info[key]= {:flag => false, :msg => err.message}
      end
    end

    render :json => info
  end

  def list
    info={:flag => false}
    begin
      files=Transcode.find_all_by_user_id(current_user.id)
      data={:prepare => [], :done => []}
      files.each do |f|
        item={}

        if (f.status == "" || f.status==nil)
          f.status = VideoHelper.get_pbs_status(f)
          f.save!
        end
        if (f.status.strip == VideoHelper.trans_status(:PREPARE) ||
            f.status.strip == VideoHelper.trans_status(:RUNNING) ||
            f.status.strip == VideoHelper.trans_status(:QUEUE) ||
            f.status.strip == VideoHelper.trans_status(:ERROR))
          item[:original]=f.video_source
          item[:target]=f
          data[:prepare]<< item
        else
          data[:done]<<f
        end
      end
      info[:flag]=true
      info[:data]=data
      render :json => info
    rescue => err
      info[:msg]=err
      render :json => info
    end
  end

  def show
    info={:flag => false}
    begin
      r_data=Transcode.find(params[:id].to_i)
      info[:flag]=true
      info[:data]=r_data
      render :json => info
    rescue => err
      info[:msg]=err
      render :json => info
    end
  end

  def delete
    info={}
    vIDs=params[:vIDs]
    vIDs.each do |vID|
      begin
        trans=Transcode.find(vID.to_i)
        if (trans==nil || trans.user_id!=current_user.id)
          raise Exception.new(VideoHelper.error_info(:ERROR_007))
        end
        v_path=File.join(trans.path, trans.filename+"."+trans.video_format)
        if File.exist? v_path
          File.delete v_path
        end
        trans.destroy
        info[vID]={:flag => true}
      rescue => err
        Rails.logger.debug err
        info[vID]={:flag => false, :msg => err.message}
      end
    end
    render :json => info
  end

  def check
    info={}
    params[:data].each_pair do |key, param|
      begin
        trans_raw_param=param[:target]
        trans_param={
            :filename => trans_raw_param[:filename],
            :video_format => trans_raw_param[:video_format],
            :path => trans_raw_param[:path],
            :vcodec => trans_raw_param[:vcodec],
            :acodec => trans_raw_param[:acodec],
            :video_bitrate => trans_raw_param[:bitrate],
            :frame_size => trans_raw_param[:frame_size],
            :frame_rate => trans_raw_param[:fps],
            :aspect => trans_raw_param[:aspect],
            :audio_sample_rate => trans_raw_param[:ar],
            :audio_channel => trans_raw_param[:ac],
            :audio_bitrate => trans_raw_param[:ab]
        }
        param=VideoHelper.check_params(trans_param)
        if (File.exist?(File.join(param[:path], param[:filename]+". "+param[:video_format])))
          raise Exception.new(VideoHelper.error_info(:ERROR_004))
        end
        trans=Transcode.find(trans_raw_param[:id].to_i)
        if (trans==nil || trans.user_id!=current_user.id)
          raise Exception.new(VideoHelper.error_info(:ERROR_007))
        end
        trans.update_attributes(param)
        trans.save
        info[key]={:flag => true, :vID => trans.id}
      rescue Exception => err
        Rails.logger.debug err
        info[key]={:flag => false, :msg => err.message}
      end
    end
    render :json => info
  end

  def submit
    info={}
    params[:data].each_pair do |key, vID|
      begin
        trans=Transcode.find(vID)
        if (trans.user_id!=current_user.id)
          raise Exception.new(VideoHelper.error_info(:ERROR_007))
        end
        if (!Dir.exists?(trans[:path]))
          FileUtils.makedirs(trans[:path])
        end
        job_id, job_stat=VideoHelper.transfer_by_pbs(trans)
        p job_id, job_stat
        trans.status=VideoHelper.parse_status_from_pbs_stat(job_stat)
        trans.pbs_job_id=job_id
        trans.save!
        info[key]={:flag => true, :status => VideoHelper.trans_status(:RUNNING)}
      rescue Exception => err
        Rails.logger.debug err
        info[key]={:flag => false, :msg => err.message}
      end
    end
    render :json => info
  end

  # pbs job
  def status
    info={}
    params[:gsv_list].each_pair do |key, vID|
      begin
        trans=Transcode.find(vID)
        if (trans.pbs_job_id=="" || trans.pbs_job_id==nil||trans.user_id!=current_user.id)
          next
        end
        job_status=VideoHelper.get_pbs_status(trans)
        if (trans.status != job_status)
          trans.status=job_status
          trans.save!
        end

        case job_status
          when VideoHelper.trans_status(:RUNNING)
            info[vID]={:status => 0}
          when VideoHelper.trans_status(:QUEUE)
            info[vID]={:status => 1}
          when VideoHelper.trans_status(:ERROR)
            info[vID]={:status => 2}
          when VideoHelper.trans_status(:COMPLETE)
            info[vID]={:status => 3}
        end
      rescue Exception => err
        Rails.logger.debug err
        trans.status=VideoHelper.trans_status(:ERROR)
        trans.save!
        info[vID]={:status => 2, :msg => err.message}
        next
      end
    end
    render :json => info
  end

  # ffmpeg command
  def status_for_ffmpeg
    info={}
    params[:gsv_list].each_pair do |vID, gsv|
      begin
        log_file="#{Rails.root}/log/video_info/#{gsv}.log"
        log_lines=VideoHelper.get_log_info(log_file)
        last_line=log_lines.split("\n")[-1]
        p last_line
      rescue Exception => err
        info[vID]={:status => 3, :msg => err.message, :gsv => gsv}
        next
      end
      if (log_lines=~%r{video:.*? audio:.*? subtitle:.*? global headers:.*? muxing overhead .*?})
        begin
          trans=Transcode.find(vID)
          trans.status=VideoHelper.trans_status(:COMPLETE)
          trans.save!
          info[vID]={:gsv => gsv, :status => 2}
        rescue Exception => err
          info[vID]={:status => 3, :msg => err.message, :gsv => gsv}
        end
      elsif (last_line.include?('frame='))
        #frame= 1800 fps= 54 q=-1.0 Lsize=    2879kB time=00:02:00.04 bitrate= 196.5kbits/s
        info_reg=%r{frame= .*? time=(.*?)\.\.*?}m.match(last_line)
        cur_time=info_reg[1]
        trans=Transcode.find(vID)
        trans.status=VideoHelper.trans_status(:ERROR)
        trans.save!
        info[vID]={:status => 1, :cur_time => cur_time, :gsv => gsv}
      else
        info[vID]={:status => 3, :msg => VideoHelper.error_info(:ERROR_001), :gsv => gsv}
      end
    end
    p info
    render :json => info
  end

  def file_list
    info={:flag => false}
    root="/"
    dir=params["dir"].to_s

    begin
      dir = File.join(Rails.root, dir) if Pathname.new(dir).relative?

      # chdir() to user requested dir (root + "/" + dir)
      Dir.chdir(File.expand_path(dir).untaint);

      # check that our base file_path still begins with root file_path
      if Dir.pwd[0, root.length] == root then

        #loop through all directories
        dirs=[]
        Dir.glob("*") do |x|
          if not File.directory?(x.untaint) then
            next
          end
          dirs.push({:path => File.join(dir, x), :name => x})
        end

        #loop through all files
        files=[]
        if (params[:fileExt]!=nil && params[:fileExt]!="")
          Dir.glob("*.{#{params[:fileExt].split(';').join(',')}}") do |x|
            if not File.file?(x.untaint) then
              next
            end
            ext = File.extname(x)[1..-1]
            files.push({:path => File.join(dir, x), :name => x, :ext => ext})
          end
        end

        info={:flag => true, :dirs => dirs, :files => files}
      else
        #only happens when someone tries to go outside your root directory...
        info[:msg]= "You are way out of your league"
      end
    rescue => err
      info[:msg]= "Internal Error ("+err.message+")"
    end
    render :json => info
  end

  def download
    trans=Transcode.find(params[:id])

    if (trans==nil || trans.user_id!=current_user.id)
      redirect_to transcode_path, :notice => "没有记录，下载失败！"
    end

    file_whole_name=trans.filename+"."+trans.video_format
    file_path=File.join(trans.path, file_whole_name)
    if (File.exist?(file_path))
      io=File.open(file_path)
      io.binmode
      send_data(io.read, :filename => file_whole_name, :disposition => 'attachment')
    else
      redirect_to transcode_path, :notice => "文件不存在，下载失败！"
    end
  end

  def video_info
    info={:flag => false, :msg => nil}
    begin
      if (params[:type]=='0')
        trans=VideoSource.find(params[:id])
      elsif (params[:type]=='1')
        trans=Transcode.find(params[:id])
      else
        raise Exception.new(VideoHelper.error_info(:ERROR_007))
      end
      info[:filename]=trans.filename
      if ((params[:type]=='0' && trans==nil) || params[:type=='1']&&(trans==nil || trans.user_id!=current_user.id))
        raise Exception.new(VideoHelper.error_info(:ERROR_007))
      end
      log_file_path="#{Rails.root}/log/upload/#{trans.filename}.#{trans.video_format}.log"
      if (File.exist?(log_file_path))
        content=IO.read(log_file_path)
        info[:flag]=true
        info[:content]=content
      else
        raise Exception.new(VideoHelper.error_info(:ERROR_007))
      end
    rescue Exception => err
      info[:flag]=false
      info[:msg]=err.message
    end

    render :json => info
  end

end

