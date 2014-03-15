module Entities
  class Badge < Grape::Entity
    include Common

    expose :identifier
    expose :level
    expose :shared_at, format_with: :timestamp
  end
end
