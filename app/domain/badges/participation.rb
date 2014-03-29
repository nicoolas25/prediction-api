module Domain
  module Badges
    module Participation
      include DSL

      kind :after_participation

      identifier 'participation'

      steps 1, 10, 50, 100, 200, 500, 1000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        [true, [participation.player], participation.created_at]
      end

      labels fr: "Joueur assidu", en: "Persevering player"
    end

    register_badge Participation
  end
end
