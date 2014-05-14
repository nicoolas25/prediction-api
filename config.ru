# Requires both the api and the web components
require 'rack/cors'
require './api'
require './web'

APPLICATION_CONFIG = {
  stakes: {
    min: 10,
    max: 10
  }
}

use Rack::Cors do
  allow do
    origins 'api.predictio.info', 'predictio.info', 'api.pulpo.info', 'pulpo.info'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end

use LoggerMiddleware if defined?(LoggerMiddleware)

run Rack::Cascade.new [Prediction::API, Prediction::Web]
