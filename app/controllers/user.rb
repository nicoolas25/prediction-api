module Controllers
  class User < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :users do
      namespace ':uid' do
        params { requires :uid, type: String }
        before { @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid]) }

        desc "Show the details of a player (account page too)"
        get do
          present @user, with: Entities::Friend, details: true
        end

        desc "Give the amount of cristals for a given user"
        get 'cristals' do
          present player.cristals, with: Entities::Cristal
        end

        desc "List the open questions for a player"
        get 'friends' do
          friends = @user.friends_dataset.eager(:social_associations).all
          present friends, with: Entities::Friend
        end

        desc "Refresh the friends list of the current user"
        params do
          requires :uid, type: String
          optional :oauth2TokenFacebook, type: String
          optional :oauth2TokenTwitter, type: String
          optional :oauth2TokenGooglePlus, type: String
        end
        post 'friends/refresh' do
          player.update_social_association_tokens(mapping_provider_tokens)
          player.social_associations.each(&:reload_friendships!)
          redirect "/v1/users/#{params[:uid]}/friends"
        end
      end
    end
  end
end
