module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    # TODO: maybe I should use reveals_at directly?
    expose :reveals_at, format_with: :timestamp, as: :created_at
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
        friends = friend_service.friends_that_answered(q)
        hash[:friends] = friends
      end

      hash
    end

    expose :answered

    expose :winnings, exclude_nil: true, if: :winning_service do |q, opts|
      opts[:winning_service].winnings_for(q)
    end

    expose :shared, if: :sharing_service do |q, opts|
      opts[:sharing_service].shared?(q)
    end

    expose :components, using: Component, if: :details

    expose :predictions, using: Prediction, if: :details
  end
end
