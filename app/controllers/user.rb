module Controllers
  class User < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :users do
      desc "Tells if an user is in the application"
      params do
        requires :nickname, type: String
      end
      get 'find_friend' do
        user = Domain::Player.where(nickname: params[:nickname]).first
        fail!(:player_not_found, 403) unless user
        fail!(:failed, 403) if player == user
        player.add_local_friend(user) rescue fail!(:failed, 403)
        {success: true}
      end

      namespace ':uid' do
        params { requires :uid, type: String }
        before { @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid]) }

        desc "Show the details of a player (account page too)"
        get do
          is_friend = player.friends_dataset.where(id: @user.id).count > 0
          present @user, with: Entities::Friend, details: true, is_friend: is_friend
        end

        desc "Un-follow the user described by uid"
        post 'unfollow' do
          fail!(:failed, 403) if player == @user
          player.remove_friend(@user)
          {success: true}
        end

        desc "Follow the user described by uid"
        post 'follow' do
          fail!(:failed, 403) if player == @user
          player.add_local_friend(@user) rescue fail!(:failed, 403)
          {success: true}
        end

        desc "Give the amount of cristals for a given user"
        get 'cristals' do
          present player.cristals, with: Entities::Cristal
        end

        desc "List the open questions for a player"
        get 'friends' do
          friends = @user.friends_dataset.eager(:social_associations).all
          friend_service = Domain::Services::Friend.new(player)
          present friends, with: Entities::Friend, friend_service: friend_service
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
          {done: true}
        end
      end
    end
  end
end
