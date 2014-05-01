require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::AdminQuestion
    mount Controllers::AdminPlayer

    mount Controllers::Activity
    mount Controllers::Badge
    mount Controllers::Bonus
    mount Controllers::Ladder
    mount Controllers::Participation
    mount Controllers::Payment
    mount Controllers::Question
    mount Controllers::Registration
    mount Controllers::Session
    mount Controllers::Share
    mount Controllers::User
  end
end
