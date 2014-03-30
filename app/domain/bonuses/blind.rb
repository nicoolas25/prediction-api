module Domain
  module Bonuses
    module Blind
      include DSL

      kind :after_loosing

      identifier 'blind'

      # When the participation doesn't succeed, get back your stakes
      apply_to! do |participation, bonus|
        if participation.winnings == 0
          stakes = participation.stakes
          player = participation.player
          player.update(cristals: Sequel.expr(:cristals) + stakes)
        end
      end

      labels fr: "Aveuglément", en: "I'm blind"
    end

    register_bonus Blind
  end
end
