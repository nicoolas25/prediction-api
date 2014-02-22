require 'logger'
require 'active_support/core_ext/numeric'

env = ENV['RACK_ENV'] || 'app'

# Keep 5 x 100 MB of logs
LOGGER ||= Logger.new("./log/#{env}.log", 5, 100.megabytes)

require 'rack/body_proxy'
require 'rack/utils'

class LoggerMiddleware
  FORMAT = %{(%0.6fs) %s "%s%s" %d from: %s\n}

  def initialize(app)
    @app = app
  end

  def call(env)
    began_at = Time.now
    status, header, body = @app.call(env)
    header = Rack::Utils::HeaderHash.new(header)
    body = Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
    [status, header, body]
  end

  private

  def log(env, status, header, began_at)
    now = Time.now
    msg = FORMAT % [
      now - began_at,
      env["REQUEST_METHOD"],
      env["PATH_INFO"],
      env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
      status.to_s[0..3],
      env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-" ]

    LOGGER.info(msg)
  end
end
