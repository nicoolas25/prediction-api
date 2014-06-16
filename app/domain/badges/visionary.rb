# encoding: utf-8

module Domain
  module Badges
    module Visionary
      include DSL

      kind :after_winning

      identifier 'visionary'

      steps 1, 10, 50, 100, 200, 1000, 2000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        if participation.winnings >= (3 * participation.stakes) && participation.winnings < (5 * participation.stakes)
          [true, [participation.player], participation.question.solved_at]
        else
          [false, []]
        end
      end

      labels fr: "Visionnaire", en: "Visionary", pt: "Visionário", es: "Visionario"
    end

    register_badge Visionary
  end
end
