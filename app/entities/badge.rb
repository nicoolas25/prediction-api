module Entities
  class Badge < Grape::Entity
    include Common

    expose :identifier
    expose :level
    expose :shared_at, format_with: :timestamp
    expose :remaining
    expose :progress
    expose :converted_to, exclude_nil: true do |b, opts|
      b.converted_to && Domain::Badge::CONVERSIONS[b.converted_to]
    end
  end
end
