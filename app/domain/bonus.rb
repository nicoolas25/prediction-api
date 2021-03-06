module Domain
  class BonusNotAvailable < Error ; end

  class Bonus < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player
    many_to_one :prediction
    many_to_one :participation, key: [:player_id, :prediction_id]

    dataset_module do
      def available_for(player)
        available.where(player_id: player.id)
      end

      def available
        where(prediction_id: nil)
      end

      def used
        exclude(prediction_id: nil)
      end
    end

    def use_for!(participation)
      update(prediction_id: participation.prediction_id)
      bonus_module.when_used(participation, self) if bonus_module.when_used?
    end

    def participation_options
      bonus_module.participation_options
    end

    def bonus_module
      @bonus_module ||= Bonuses.modules[identifier]
    end

    class << self
      def find_for_participation(player, identifier)
        unless bonus = dataset.available_for(player).where(identifier: identifier).first
          raise BonusNotAvailable.new(:bonus_not_available) unless bonus
        end

        bonus
      end
    end
  end
end
