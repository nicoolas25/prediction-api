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

        desc "List the open questions for a player"
        get 'friends' do
          friends = @user.friends_dataset.eager(:social_associations).all
          present friends, with: Entities::Friend
        end

        desc "Refresh the friends list of the current user"
        get 'friends/refresh' do
          player.social_associations.each(&:reload_friendships!)
          redirect "/v1/users/#{params[:uid]}/friends"
        end
      end
    end
  end
end
