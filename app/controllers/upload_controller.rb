# coding: utf-8
class UploadController < ApplicationController
  layout 'basic'
  include ActionController::RequestForgeryProtection
  before_filter :authenticate_user!

  def index
    session[:authenticity_token]=form_authenticity_token
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
      render :json => {:flag => false, :msg => err.message}
    end

  end

  def create
    info={:flag => nil}
    begin
      path=(params[:path]==nil) ? $default_upload_file_path : params[:path]
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
      info[:flag]=false
      info[:msg]= {:type => VideoHelper.error_info(:ERROR_002), :info => err.message}
      p info
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
        if (File.exist?(File.join($default_upload_file_path, filename)))
          info[:data][key]={:msg => filename+VideoHelper.error_info(:ERROR_004)}
        end
      end
      if (info[:data].size>0)
        info[:flag]=false
      end
    rescue Exception => err
      info={:error => true, :msg => err.message}
    end
    p info
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
      log_file_path=File.join($upload_video_info_path, trans.filename+"."+trans.video_format+".log")
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
