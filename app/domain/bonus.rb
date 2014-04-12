module Domain
  class Bonus < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player
    many_to_one :prediction
    many_to_one :participation, key: [:player_id, :prediction_id]

    dataset_module do
      def available_for(player)
        where(player_id: player.id, prediction_id: nil)
      end
    end
  end
end
