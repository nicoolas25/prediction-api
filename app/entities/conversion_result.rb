module Entities
  class ConversionResult < Grape::Entity
    include Common

    expose :cristals do |p, opts|
      p.cristals
    end

    expose :distinct_bonuses, using: Entities::Bonus, as: :bonus
  end
end


