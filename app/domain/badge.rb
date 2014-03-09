module Domain
  class Badge < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player

    dataset_module do
      def visible
        where(Sequel.expr(:level) > 0)
      end

      def for(identifier)
        where(identifier: identifier)
      end
    end

    def self.increase_counts_for(players, badge_module)
      identifier = badge_module.identifier
      players.each do |player|
        last_badge = player.badges_dataset.for(identifier).order(Sequel.desc(:level)).first
        count = (last_badge.try(:count) || 0) + 1
        level = badge_module.level_for(count)
        if last_badge.present? && level == last_badge.level
          last_badge.update(Sequel.expr(:count) + 1)
        else
          create({
            player_id: player.id,
            identifier: identifier,
            count: count,
            level: level,
            created_at: Time.now
          })
        end
      end
    end
  end
end
