require 'grape'

require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::Question
    mount Controllers::Registration
    mount Controllers::Session
  end
end
