module Entities
  class Badge < Grape::Entity
    include Common

    expose :identifier
    expose :level
    expose :shared_at, format_with: :timestamp
    expose :remaining
    expose :progress
  end
end
