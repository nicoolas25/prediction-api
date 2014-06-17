# encoding: utf-8

module Domain
  module Badges
    module Looser
      include DSL

      kind :after_loosing

      identifier 'looser'

      steps 1, 10, 50, 100, 200, 1000, 2000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        [true, [participation.player], participation.question.solved_at]
      end

      labels fr: "KO", en: "KO", pt: "KO", es: "KO", ru: "KO"
    end

    register_badge Looser
  end
end
