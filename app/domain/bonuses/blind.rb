# encoding: utf-8

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
          player.increment_cristals_by!(stakes)
        end
      end

      expected_winnings do |stakes, actual_winnings|
        actual_winnings == 0 ? stakes : 0
      end

      labels fr: "Lucky loser", en: "Lucky loser", pt: "Lucky loser", es: "Lucky Loser", ru: "Lucky loser"
    end

    register_bonus Blind
  end
end
