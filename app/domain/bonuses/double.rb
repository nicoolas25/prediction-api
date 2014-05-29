# encoding: utf-8

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

      expected_winnings do |stakes, actual_winnings|
        actual_winnings
      end

      when_used do |participation, bonus|
        player = participation.player
        stakes = participation.stakes

        player.decrement_cristals_by!(stakes)
      end

      labels fr: "Quitte ou Double", en: "Quit or Double", pt: "Tudo ou nada", es: "Salir o Doble"
    end

    register_bonus Double
  end
end
