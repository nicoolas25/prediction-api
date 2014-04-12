module Domain
  module Bonuses
    module Double
      include DSL

      kind :after_solving

      identifier 'double'

      # When the participation ends, get 20 cristals
      apply_to! do |participation, bonus|
        player = participation.player
        winnings = participation.winnings

        if winnings > 0
          player.increment_cristals_by!(winnings)
        end
      end

      labels fr: "Double", en: "Double"
    end

    register_bonus Double
  end
end
