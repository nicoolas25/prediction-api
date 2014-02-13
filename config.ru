# Requires both the api and the web components
require 'rack/cors'
require './api'
require './web'

APPLICATION_CONFIG = {
  stakes: {
    min: 10,
    max: 1000
  },
  avatars: {
    small: {
      facebook: "http://graph.facebook.com/__id__/picture?height=100&width=100"
    },
    big: {
      facebook: "http://graph.facebook.com/__id__/picture?height=300&width=300"
    }
  }
}

use Rack::Cors do
  allow do
    origins 'api.predictio.info', 'predictio.info'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end

run Rack::Cascade.new [Prediction::API, Prediction::Web]
