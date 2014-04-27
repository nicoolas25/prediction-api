require 'securerandom'
require 'twitter'

module SocialAPI
  class Local < Base
    # Social ID is the application ID
    # This should be used only to add internal friendships
    # bounded inside the application.

    def first_name
      nil
    end

    def last_name
      nil
    end

    def social_id
      @social_id
    end

    def avatar_url
      nil
    end

    def email
      nil
    end

    def friend_ids
      return [] unless social_id

      ids = DB[:friendships].
        where(provider: provider_id, left_id: social_id).
        select(:right_id).
        all

      ids.map { |r| r['right_id'].to_s }
    end

    def share(locale, message, id)
      false
    end
  end
end
