module Entities
  class Question < Grape::Entity
    # FIXME: merge with player formatter into a common module
    format_with(:timestamp) { |dt| dt.to_i }

    expose :id

    expose :expires_at, format_with: :timestamp

    expose :dev_info do |q, opts|
      q.labels['dev']
    end

    expose :label do |q, opts|
      q.labels[opts[:locale]]
    end

    expose :components, using: Component, if: :details
  end
end
