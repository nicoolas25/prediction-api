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

      labels fr: "Lucky loser", en: "Lucky loser", pt: "Lucky loser"
    end

    register_bonus Blind
  end
end
