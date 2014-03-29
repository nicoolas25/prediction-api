module Domain
  module Badges
    module Incredible
      include DSL

      kind :after_winning

      identifier 'incredible'

      steps 1, 10, 50, 100, 200, 500, 1000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        if participation.winnings >= (5 * participation.stakes)
          [true, [participation.player], participation.question.solved_at]
        else
          [false, []]
        end
      end

      labels fr: "Incroyable", en: "Incredible"
    end

    register_badge Incredible
  end
end
