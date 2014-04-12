module Domain
  module Bonuses
    module Cresus
      include DSL

      kind :after_solving

      identifier 'cresus'

      # When the participation ends, get 20 cristals
      apply_to! do |participation, bonus|
        participation.player.increment_cristals_by!(20)
      end

      labels fr: "Appelez moi Cresus", en: "Call me Cresus"
    end

    register_bonus Cresus
  end
end
