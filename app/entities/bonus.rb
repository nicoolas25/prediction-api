module Entities
  class Bonus < Grape::Entity
    include Common

    expose :identifier

    expose :used, if: :bonus_service do |b, opts|
      opts[:bonus_service].used(b.identifier)
    end

    expose :remaining, if: :bonus_service do |b, opts|
      opts[:bonus_service].remaining(b.identifier)
    end
  end
end
