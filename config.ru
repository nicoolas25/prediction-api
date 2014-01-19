require 'grape'

require './config/log'
require './db/connect'
require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::Registration
    mount Controllers::Session
  end
end

run Prediction::API
