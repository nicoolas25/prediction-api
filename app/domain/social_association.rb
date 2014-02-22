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

  protected

    def add_induced_friendships!
      friend_ids = api.friend_ids

      assocs = SocialAssociation.dataset.
        where(provider: provider).
        where(id: friend_ids)

      # Remove player's friends from selected social associations
      if api.symetric_friends?
        assocs = assocs.
          exclude(player_id: player.friends_dataset.select(:id))
      end

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
