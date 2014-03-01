module Entities
  class ActivityAnswer < Grape::Entity
    include Common

    expose :player_id

    expose :created_at, format_with: :timestamp

    expose :question, using: Question
  end

  class ActivitySolution < Grape::Entity
    include Common

    expose :player_id

    expose :created_at do |s, opts|
      s.question.solved_at.to_i
    end

    expose :winnings

    expose :question, using: Question
  end

  class Activity < Grape::Entity
    expose :answers, using: ActivityAnswer
    expose :solutions, using: ActivitySolution
    expose :friends, using: Friend
  end
end

