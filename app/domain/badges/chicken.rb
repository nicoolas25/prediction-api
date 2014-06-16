# encoding: utf-8

module Domain
  module Badges
    module Chicken
      include DSL

      kind :after_winning

      identifier 'chicken'

      steps 1, 10, 50, 100, 200, 1000, 2000

      # Matches participations won with a blind bonus
      matches? do |participation|
        if participation.bonus && participation.bonus.identifier == 'blind'
          [true, [participation.player], participation.question.solved_at]
        else
          [false, []]
        end
      end

      labels fr: "Poule mouillée", en: "Chicken", pt: "Chicken", es: "Cobarde"
    end

    register_badge Chicken
  end
end
