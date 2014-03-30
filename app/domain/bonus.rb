module Domain
  class Bonus < ::Sequel::Model
    set_dataset :bonuses

    unrestrict_primary_key

    many_to_one :player
    many_to_one :prediction

    # Custom association based on participation primary key
    one_to_one :participation,
               dataset: proc { |r|
                 r.association_dataset.
                   where(prediction_id: :bonuses__prediction_id).
                   where(player_id: :bonuses__player_id)
                   select_all(:participations)
               }

    dataset_module do
      def available_for(player)
        where(player_id: player.id, prediction_id: nil)
      end
    end
  end
end
