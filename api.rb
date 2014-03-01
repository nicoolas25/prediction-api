require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::AdminQuestion
    mount Controllers::AdminPlayer

    mount Controllers::Activity
    mount Controllers::Participation
    mount Controllers::Question
    mount Controllers::Registration
    mount Controllers::Session
    mount Controllers::User
  end
end
