module Workers
  # Check if the relation for asymetric social network are symetric
  class FriendExplorer
    include Sidekiq::Worker

    def perform(player_id, provider_name)
      provider = SocialAPI::PROVIDERS.index(provider_name)
      player = Domain::Player.first(id: player_id)
      if player
        assoc = player.social_associations_dataset.where(provider: provider).first
        if assoc
          assoc.find_and_create_local_symmetries
        else
          LOGGER.error("The player #{player.nickname} has no social association for #{provider_name}")
        end
      else
        LOGGER.error("The player of id #{player_id} is not found")
      end
    rescue Domain::Error
      LOGGER.error("Unexpected error during async FriendExplorer.perform: #{$!.message}")
    end
  end
end
