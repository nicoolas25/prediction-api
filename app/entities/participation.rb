module Entities
  class Participation < Grape::Entity
    expose :question_id
    expose :prediction_id
    expose :badges, using: Badge
    expose :earned_bonus, using: Bonus
    expose :cristals do |p, opts|
      p.player.cristals
    end
  end
end
