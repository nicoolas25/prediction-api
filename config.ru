require 'active_support'
require 'active_support/deprecation'
require 'active_support/core_ext'

# All the application depends on the log
require './config/log'

# All the application depends on the database connection
require './db/connect'

# Requires both the api and the web components
require './api'
require './web'

run Rack::Cascade.new [Prediction::API, Prediction::Web]
