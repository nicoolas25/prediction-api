module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    expose :created_at, format_with: :timestamp
    expose :reveals_at, format_with: :timestamp
    expose :expires_at, format_with: :timestamp

    expose :event_at do |q, opts|
      q.event_at.try(:to_i) || nil
    end

    expose :labels, if: :admin
    expose :label, if: :locale do |q, opts|
      q.labels[opts[:locale]]
    end

    expose :statistics do |q, opts|
      hash = {
        total: q.amount,
        participations: q.players_count
      }

      # Expose the friends that answered the question
      if friend_service = opts[:friend_service]
        friends = friend_service.friends_that_answered(q) || []

        # Expose the size of friends
        hash[:friends_count] = friends.size

        # Expose list of friends (only the end to save bandwidth)
        if !opts[:details] && friends.size > 2
          hash[:friends] = friends[-3..-1]
        else
          hash[:friends] = friends
        end
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

    expose :bonus_winnings, if: :winning_service do |q, opts|
      opts[:winning_service].bonus_winnings_for(q)
    end

    expose :bonus, if: ->(q, opts){ opts[:winning_service].try(:answered?, q) } do |q, opts|
      opts[:winning_service].bonus_for(q)
    end

    expose :shared, if: :sharing_service do |q, opts|
      opts[:sharing_service].shared?(q)
    end

    expose :components, using: Component, if: :details

    expose :predictions, using: Prediction, if: :details

    expose :tags do |q, opts|
      # TODO: Handle this client side
      q.tags.map(&:keyword).sort_by { |kw| kw.start_with?('c/') ? 1 : 0 }
    end

    expose :pending, if: :admin
  end
end
