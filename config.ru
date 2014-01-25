# Requires both the api and the web components
require './api'
require './web'

run Rack::Cascade.new [Prediction::API, Prediction::Web]
