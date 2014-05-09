module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    expose :created_at, format_with: :timestamp
    expose :reveals_at, format_with: :timestamp
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

    expose :made_prediction do |q, opts|
      opts[:made_prediction] || opts[:winning_service].try(:answered?, q) || opts[:event_service].try(:have_a_participation?, q) || false
    end

    expose :winnings, if: :winning_service do |q, opts|
      opts[:winning_service].winnings_for(q)
    end

    expose :bonus, if: ->(q, opts){ opts[:winning_service].try(:answered?, q) } do |q, opts|
      opts[:winning_service].bonus_for(q)
    end

    expose :shared, if: :sharing_service do |q, opts|
      opts[:sharing_service].shared?(q)
    end

    expose :components, using: Component, if: :details

    expose :predictions, using: Prediction, if: :details
  end
end
