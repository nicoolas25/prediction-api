# encoding: utf-8

module Domain
  module Bonuses
    module Cresus
      include DSL

      kind :after_solving

      identifier 'cresus'

      # When the participation ends, get 20 cristals
      apply_to! do |participation, bonus|
        participation.player.increment_cristals_by!(20)
      end

      expected_winnings do |stakes, actual_winnings|
        20
      end

      labels fr: "Crésus", en: "Call me Cresus", pt: "Crésus", es: "Cresus", ru: "Call me Cresus"
    end

    register_bonus Cresus
  end
end
