# encoding: utf-8

module Domain
  module Badges
    module God
      include DSL

      kind :after_participation

      identifier 'god'

      steps 1, 10, 50, 100, 200, 500, 1000

      # Matches any participation having a bonus
      matches? do |participation|
        if participation.bonus.present?
          [true, [participation.player], participation.created_at]
        else
          [false, []]
        end
      end

      labels fr: "God of bonus", en: "God of bonus", pt: "Deus do bônus"
    end

    register_badge God
  end
end
