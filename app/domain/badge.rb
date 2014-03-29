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

    def visible?
      level > 0
    end

    def labels
      badge_module.labels
    end

    def badge_module
      @badge_module ||= Badges.modules[identifier]
    end

    def self.increase_counts_for(players, badge_module, time=nil, increment=1)
      badges = []
      identifier = badge_module.identifier
      players.each do |player|
        last_badge = player.badges_dataset.for(identifier).order(Sequel.desc(:level)).first
        count = (last_badge.try(:count) || 0) + increment
        level = badge_module.level_for(count)
        if last_badge.present? && level < last_badge.level
          last_badge.update(count: Sequel.expr(:count) + increment)
        else
          badges << create({
            player_id: player.id,
            identifier: identifier,
            count: count,
            level: level,
            created_at: (time || Time.now)
          })
        end
      end
      badges
    end
  end
end
