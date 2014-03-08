module Domain
  module Badges
    module Participation
      include DSL

      kind :after_participation

      identifier "participation"

      steps 5, 50, 100, 200, 500, 1000

      # Matches any participation, update the Badge of the related Player
      matches? do |participation|
        [true, [participation.player_id]]
      end
    end

    register_badge Participation
  end
end
