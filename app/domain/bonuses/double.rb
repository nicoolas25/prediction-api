module Domain
  module Bonuses
    module Double
      include DSL

      kind :after_solving

      identifier 'double'

      # When the participation ends, get 20 cristals
      apply_to! do |participation, bonus|
        player = participation.player
        stakes = participation.stakes
        winnings = participation.winnings
        if winnings == 0
          player.update(cristals: Sequel.expr(:cristals) - stakes)
        else
          player.update(cristals: Sequel.expr(:cristals) + winnings)
        end
      end

      labels fr: "Double", en: "Double"
    end

    register_bonus Double
  end
end
