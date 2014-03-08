module Domain
  class Badge < ::Sequel::Model
    def self.prepare(player_ids, identifier)
      badges_dataset = dataset.where(player_id: player_ids, identifier: identifier)
      DB.transaction(isolation: :repeatable, retry_on: [Sequel::SerializationFailure]) do
        unless badges_dataset.count == player_ids.size
          existing_player_ids = badges_dataset.select(:id).map(&:id)
          missing_player_ids = player_ids - existing_player_ids
          new_rows = missing_player_ids.map{ |id| { player_id: id, identifier: identifier, count: 0 } }
          dataset.multi_insert(new_rows)
        end
      end
      badges_dataset
    end
  end
end
