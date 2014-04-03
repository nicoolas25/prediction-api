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

    def remaining
      return 0 if badge_module.steps.size == level

      badge_module.steps[level] - count
    end

    def progress
      return 100 if badge_module.steps.size == level

      total = badge_module.steps[level]
      step  = count

      if level >= 1
        prev   = badge_module.steps[level - 1]
        total -= prev
        step  -= prev
      end

      ((step / total.to_f) * 100).to_i
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
        if last_badge.present? && level <= last_badge.level
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
