module Entities
  class Question < Grape::Entity
    include Common

    expose :id

    expose :expires_at, format_with: :timestamp

    expose :label do |q, opts|
      q.labels[opts[:locale]]
    end

    expose :dev_info, exclude_nil: true do |q, opts|
      q.labels['dev']
    end

    expose :components, using: Component, if: :details
  end
end
