require 'logger'
require 'active_support/core_ext/numeric'

env = ENV['RACK_ENV'] || 'app'

# Keep 5 x 100 MB of logs
LOGGER ||= Logger.new("./log/#{env}.log", 5, 100.megabytes)

class LoggerMiddleware
  FORMAT_BGN         = %{Receive %s "%s%s" from %s}
  FORMAT_END         = %{Completed %d (%0.6fs)\nBody: %s\n}
  FORMAT_END_WO_BODY = %{Completed %d (%0.6fs)\n}

  def initialize(app)
    @app = app
  end

  def call(env)
    began_at = Time.now
    log_bgn(env)
    status, header, body = @app.call(env)
    log_end(status, header, began_at, body)
    [status, header, body]
  end

  private

  def log_bgn(env)
    msg = FORMAT_BGN % [
      env["REQUEST_METHOD"],
      env["PATH_INFO"],
      env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
      env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-" ]

    LOGGER.info(msg)
  end

  def log_end(status, header, began_at, body)
    if header['Content-Type'] =~ /json/
      body = body.instance_eval{ @body } if body.kind_of?(Rack::BodyProxy)
      body = body.body                   if body.kind_of?(Rack::Response)
      body = body.first                  if body.kind_of?(Array)
      msg  = FORMAT_END % [ status.to_s[0..3], Time.now - began_at, body ]
    else
      msg = FORMAT_END_WO_BODY % [ status.to_s[0..3], Time.now - began_at]
    end

    LOGGER.info(msg)
  end
end
