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
          friend = player.circle_dataset.where(id: @user.id).count > 0
          present @user, with: Entities::Friend, details: true, friend: friend
        end

        desc "List the open questions for a player"
        get 'friends' do
          mine = @user == player
          friends = mine ?
            @user.friends_dataset.eager(:social_associations).all :
            @user.friends
          present friends, with: Entities::Friend, friend: mine
        end
      end
    end
  end
end
