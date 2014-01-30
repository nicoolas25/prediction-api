require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::Participation
    mount Controllers::Question
    mount Controllers::Registration
    mount Controllers::Session
  end
end
