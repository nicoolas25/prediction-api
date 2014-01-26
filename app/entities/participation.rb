module Entities
  class Participation < Grape::Entity
    expose :question_id
    expose :prediction_id
  end
end
