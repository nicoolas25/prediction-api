module Domain
  class SocialAssociation < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player

    def validate
      super
      errors.add(:id, 'is already taken') if new? && SocialAssociation.where(provider: provider, id: id).count > 0
    end

    def after_create
      super
      add_induced_friendships!
    end

    def after_destroy
      super
      remove_induced_friendships!
    end

    # This is not used by the application right now
    # it's for maintenance purpose
    def reload_friendships!
      remove_induced_friendships!
      add_induced_friendships!
    end

  protected

    def remove_induced_friendships!
      ds = DB[:friendships].where(provider: provider)

      if api.symetric_friends?
        ds = ds.where(Sequel.expr(left_id: player_id) | Sequel.expr(right_id: player_id))
      else
        ds = ds.where(left_id: player_id)
      end

      ds.delete
    end

    def add_induced_friendships!
      friend_ids = api.friend_ids

      assocs = SocialAssociation.dataset.
        where(provider: provider).
        where(id: friend_ids)

      # Remove player's friends from selected social associations
      # This make the operation idempotent
      assocs = assocs.exclude(player_id: player.friends_dataset.select(:id))

      # Insert a new friendship for each of the selected social assoc
      DB[:friendships].insert(
        [:provider, :left_id, :right_id],
        assocs.select(Sequel.expr(provider), Sequel.expr(player_id), :player_id)
      )
    end

    def api
      @api ||= SocialAPI.for(provider, token, id)
    end
  end
end
