# coding: utf-8
class UploadController < ApplicationController
  layout 'basic'
  include ActionController::RequestForgeryProtection

  before_filter :authenticate_user!

  def index
    session[:authenticity_token]=form_authenticity_token
    Rails.logger.info $VTRANS_CONFIG['upload_path']
    respond_to do |format|
      format.html
    end
  end

  def delete
    begin
      info={}
      videoIds=params[:data]
      done_cnt=0
      error_cnt=0
      for id in videoIds
        u=Upload.where(:id => id, :user_id => current_user.id)[0]
        begin
          u_path=File.join(u.path, u.filename+"."+u.video_format)
          if File.exist? u_path
            FileUtils.remove_file(u_path)
          end
          u.destroy
          done_cnt+=1
        rescue Exception => err
          error_cnt+=1
          info[id]={:flag => false, :msg => err.message}
        end
      end
      info[:flag]=true
      info[:done_cnt]=done_cnt
      info[:error_cnt]=error_cnt
      render :json => info
    rescue Exception => err
      Rails.logger.debug err.message
      render :json => {:flag => false, :msg => err.message}
    end

  end

  def create
    info={:flag => nil}
    begin
      # check the upload is validated
      path=params[:path]
      if path == '' or path == nil?
        raise Exception.new('目标路径不能为空')
      end

      original_filename=params[:Filedata].original_filename
      file_path =File.join(path, original_filename)
      dest_dirname=File.dirname(file_path)

      if !Dir.exists?(dest_dirname)
        FileUtils.makedirs(dest_dirname)
      end

      FileUtils.mv(params[:Filedata].tempfile.path, file_path)
      v_info=VideoHelper.get_video_info_by_path(file_path)
      v_info[:user_id]=current_user.id.to_s
      Upload.create(v_info)

      info[:flag]=true
      render :json => info
    rescue => err
      Rails.logger.debug err.message
      if File.exist? file_path
        FileUtils.remove_file file_path
      end

      info[:flag]=false
      info[:msg]= {:type => VideoHelper.error_info(:ERROR_002), :info => err.message}
      render :json => info
    end
  end

  def list
    info={:flag => false}
    begin
      files=Upload.find_all_by_user_id(current_user.id.to_s)
      info[:flag]=true
      info[:data]=files
      render :json => info
    rescue => err
      info[:msg]=err
      render :json => info
    end
  end

  def check
    begin
      info={:flag => true, :error => false, :data => {}}
      params[:data].each_pair do |key, filename|
        if (File.exist?(File.join($VTRANS_CONFIG['upload_path'], filename)))
          info[:data][key]={:msg => filename+VideoHelper.error_info(:ERROR_004)}
        end
      end
      if (info[:data].size>0)
        info[:flag]=false
      end
    rescue Exception => err
      Rails.logger.debug err.message
      info={:error => true, :msg => err.message}
    end
    render :json => info
  end

  def video_info
    info={:flag => false, :msg => nil}
    begin
      trans=Upload.find(params[:id])
      info[:filename]=trans.filename
      if (trans==nil || trans.user_id!=current_user.id)
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
      Rails.logger.debug err.message
      info[:flag]=false
      info[:msg]=err.message
    end

    render :json => info
  end

  def download
    video=Upload.find(params[:id])

    if (video==nil || video.user_id!=current_user.id)
      redirect_to upload_path, :notice => "没有记录，下载失败！"
    end

    file_whole_name=video.filename+"."+video.video_format
    file_path=File.join(video.path, file_whole_name)
    if (File.exist?(file_path))
      io=File.open(file_path)
      io.binmode
      send_data(io.read, :filename => file_whole_name, :disposition => 'attachment')
    else
      redirect_to upload_path, :notice => "文件不存在，下载失败！"
    end
  end
end
