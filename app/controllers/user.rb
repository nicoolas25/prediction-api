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
          friends =
            if user == player
              @user.friends_dataset.eager(:social_associations).all
            else
              @user.friends
            end

          present friends, with: Entities::Friend, mine: user == player
        end
      end
    end
  end
end
