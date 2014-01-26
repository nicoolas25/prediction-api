# Requires both the api and the web components
require './api'
require './web'

APPLICATION_CONFIG = {
  stake: {
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

run Rack::Cascade.new [Prediction::API, Prediction::Web]
