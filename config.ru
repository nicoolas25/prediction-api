# Requires both the api and the web components
require 'rack/cors'
require './api'
require './web'

APPLICATION_CONFIG = {
  stakes: {
    min: 10,
    max: 10
  },
  avatars: {
    small: {
      facebook: "http://graph.facebook.com/__id__/picture?height=100&width=100",
      googleplus: "https://plus.google.com/s2/photos/profile/__id__?sz=100",
      twitter: ""
    },
    big: {
      facebook: "http://graph.facebook.com/__id__/picture?height=300&width=300",
      googleplus: "https://plus.google.com/s2/photos/profile/__id__?sz=300",
      twitter: ""
    }
  }
}

use Rack::Cors do
  allow do
    origins 'api.predictio.info', 'predictio.info'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end

use LoggerMiddleware if defined?(LoggerMiddleware)

run Rack::Cascade.new [Prediction::API, Prediction::Web]
