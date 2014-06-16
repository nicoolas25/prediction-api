# encoding: utf-8

module Domain
  module Badges
    module Glutton
      include DSL

      kind :after_loosing

      identifier 'glutton'

      steps 1, 10, 50, 100, 200, 1000, 2000

      # Matches participations loosed with a double bonus
      matches? do |participation|
        if participation.bonus && participation.bonus.identifier == 'double'
          [true, [participation.player], participation.question.solved_at]
        else
          [false, []]
        end
      end

      labels fr: "Gourmand", en: "Glutton", pt: "Guloso", es: "Codicioso"
    end

    register_badge Glutton
  end
end
