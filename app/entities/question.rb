module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    expose :expires_at, format_with: :timestamp

    expose :labels, if: :admin
    expose :label, if: :locale do |q, opts|
      q.labels[opts[:locale]]
    end

    expose :statistics do |q, opts|
      hash = {
        total: q.amount,
        participations: q.players_count
      }

      # Expose the number of friends that answered the question
      if friend_service = opts[:friend_service]
        count = friend_service.friends_that_answered(q)
        hash[:friends] = count
      end

      hash
    end

    expose :answered

    expose :winnings, if: :winning_service do |q, opts|
      opts[:winning_service].winnings_for(q)
    end

    expose :components, using: Component, if: :details

    expose :predictions, using: Prediction, if: :details
  end
end
