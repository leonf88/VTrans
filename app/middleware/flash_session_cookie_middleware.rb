require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_VTrans_session') # !!! change it to your own!
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['REQUEST_PATH'] == "/upload" # env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      Rails.logger.debug "===== (before frozen) env['HTTP_COOKIE']: #{env['HTTP_COOKIE'].inspect}"
      req = Rack::Request.new(env)

      unless req.params[@session_key].nil?
        env['HTTP_COOKIE'] = [@session_key, req.params[@session_key]].join('=').freeze
      end
      Rails.logger.debug "===== (after frozen) env['HTTP_COOKIE']: #{env['HTTP_COOKIE'].inspect}"
    end

    @app.call(env)
  end
end