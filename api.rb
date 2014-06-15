require './app/controllers'

module Prediction
  class API < Grape::API
    mount Controllers::AdminQuestion
    mount Controllers::AdminPlayer

    mount Controllers::Activity
    mount Controllers::Badge
    mount Controllers::Bonus
    mount Controllers::Conversion
    mount Controllers::Ladder
    mount Controllers::Match
    mount Controllers::Participation
    mount Controllers::Payment
    mount Controllers::Question
    mount Controllers::Registration
    mount Controllers::Session
    mount Controllers::Share
    mount Controllers::Tag
    mount Controllers::User
  end
end
