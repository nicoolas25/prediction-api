module Controllers
  class User < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :users do
      namespace ':uid' do
        params { requires :uid, type: String }
        before {
          @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid])
          @mine = @user == player
        }

        desc "Show the details of a player (account page too)"
        get do
          present @user, with: Entities::Friend, details: true, mine: @mine
        end

        desc "List the open questions for a player"
        get 'friends' do
          friends = @mine ?
            @user.friends_dataset.eager(:social_associations).all :
            @user.friends
          present friends, with: Entities::Friend, mine: @mine
        end
      end
    end
  end
end
