module Collections
  module SocialAssociations
    def self.fill(player)
      sas = DB[:social_associations].where(player_id: player.id).all.map do |attrs|
        # Convert the integer to the text name of the provider
        attrs[:provider] = SocialAPI.provider(attrs[:provider])

        # Link the player instead of having the player_id
        attrs.delete(:player_id)
        attrs[:player] = player

        Domain::SocialAssociation.new(attrs)
      end

      player.social_associations = sas
    end
  end
end
