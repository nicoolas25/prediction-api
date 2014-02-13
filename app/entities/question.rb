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
      {
        total: q.amount,
        participations: q.players_count
      }
    end

    expose :answered

    expose :components, using: Component, if: :details
  end
end
