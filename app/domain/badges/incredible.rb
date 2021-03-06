# encoding: utf-8

module Domain
  module Badges
    module Incredible
      include DSL

      kind :after_winning

      identifier 'incredible'

      steps 1, 10, 50, 100, 200, 1000, 2000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        if participation.winnings >= (5 * participation.stakes)
          [true, [participation.player], participation.question.solved_at]
        else
          [false, []]
        end
      end

      labels fr: "Extra-lucide", en: "Incredible", pt: "Clarividente", es: "Extra lucido", ru: "Incredible"
    end

    register_badge Incredible
  end
end
