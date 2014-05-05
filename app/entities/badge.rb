module Entities
  class Badge < Grape::Entity
    include Common

    expose :identifier
    expose :level
    expose :shared_at, format_with: :timestamp
    expose :remaining
    expose :progress
    expose :converted_to do |b, opts|
      b.converted_to && Domain::Badge::CONVERSIONS[b.converted_to]
    end
    expose :earnable_cristals do |b, opts|
      b.badge_module.earning_cristals[b.level - 1]
    end
    expose :earnable_bonus do |b, opts|
      b.badge_module.earning_bonuses[b.level - 1]
    end
  end
end
