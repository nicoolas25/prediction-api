module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    expose :expires_at, format_with: :timestamp

    expose :label do |q, opts|
      opts[:locale] ? q.labels[opts[:locale]] : q.labels
    end

    expose :dev_info, exclude_nil: true do |q, opts|
      q.labels['dev']
    end

    expose :statistics do |q, opts|
      {
        total: q.amount,
        participations: q.players_count
      }
    end

    expose :components, using: Component, if: :details
  end
end
