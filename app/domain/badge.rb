module Domain
  class Badge < ::Sequel::Model
    many_to_one :player

    def self.prepare(player_ids, identifier)
      badges_dataset = dataset.where(player_id: player_ids, identifier: identifier)
      unless badges_dataset.count == player_ids.size
        existing_player_ids = badges_dataset.select(:player_id).map(&:player_id)
        missing_player_ids = player_ids - existing_player_ids
        new_rows = missing_player_ids.map{ |id| { player_id: id, identifier: identifier, count: 0 } }
        dataset.multi_insert(new_rows)
      end
      badges_dataset
    end
  end
end
