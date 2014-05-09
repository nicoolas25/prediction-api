module Domain
  module Bonuses
    module Lucky
      # This bonus is never triggered only apply when_used

      BONUS_CHANCES = 0.6

      include DSL

      kind :none

      identifier 'lucky'

      labels fr: "Jour de chance", en: "Feeling lucky"

      participation_options do
        { chances: BONUS_CHANCES }
      end
    end

    register_bonus Lucky
  end
end
