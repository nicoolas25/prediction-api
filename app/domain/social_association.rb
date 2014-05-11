module Domain
  class SocialAssociation < ::Sequel::Model
    REFRESH_DELAY = 10.minutes

    unrestrict_primary_key

    many_to_one :player
    many_to_one :extra_information

    def validate
      super
      errors.add(:id, 'is already taken') if new? && SocialAssociation.where(provider: provider, id: id).count > 0
    end

    def before_create
      super
      self.last_updated_at = Time.now - REFRESH_DELAY
    end

    def after_create
      super
      add_induced_friendships!
      update_extra_information!
      Workers::FriendExplorer.perform_async(player.id, api.provider_name)
    end

    def after_destroy
      super
      remove_induced_friendships!
    end

    def alive?
      api.valid?(true)
    end

    def expired?
      expires_at <= Time.now
    end

    def expires_at
      last_updated_at + REFRESH_DELAY
    end

    def update_with_api!(out_api)
      update(token: out_api.token, avatar_url: out_api.avatar_url, email: out_api.email)
      update_extra_information!(out_api)
    end

    def touch!
      update(last_updated_at: Time.now)
    end

    def share(locale, message, id)
      api.share(locale, message, id)
    end

    def reload_friendships!(force=false)
      if (force || expired?) && alive?
        remove_induced_friendships!
        add_induced_friendships!
        touch!
      end
    end

    def find_and_create_local_symmetries
      unless api.symetric_friends?
        friend_with_me = DB[:friendships].
          where(provider: provider, right_id: player_id).
          select(:left_id)
        friend_ids = DB[:friendships].
          where(provider: provider, left_id: player_id).
          exclude(right_id: friend_with_me).
          select(:right_id)

        symmetries = []
        Player.where(id: friend_ids).eager(:social_associations).each do |p|
          assoc = p.social_associations.find{ |assoc| assoc.provider == provider }
          if assoc && assoc.friend_with?(id)
            symmetries << { provider: provider, left_id: p.id, right_id: player_id }
          end
        end
        DB[:friendships].multi_insert(symmetries)
      end
    end

    #
    # This is not used by the application right now, it's for maintenance purpose
    #

    def reload_avatar!
      if api.valid?(true)
        update(avatar_url: api.avatar_url)
      end
    end

  protected

    def update_extra_information!(out_api=nil)
      content = Sequel.hstore((out_api || api).extra_informations)
      if extra_information
        extra_information.update(content: content)
      else
        self.extra_information = Domain::ExtraInformation.create(content: content)
        save_changes
      end
    end

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

    def friend_with?(social_id)
      # TODO: Add an interface to the social api lib to have faster queries
      api.friend_ids.include?(social_id)
    end

    def api
      @api ||= SocialAPI.for(provider, token, id)
    end
  end
end
