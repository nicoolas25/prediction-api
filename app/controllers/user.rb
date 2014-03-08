module Controllers
  class User < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :users do
      namespace ':uid' do
        params { requires :uid, type: String }

        desc "List the open questions for a player"
        get 'friends' do
          # Get the referenced player
          user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid])
          present user.friends, with: Entities::Friend, details: true, mine: user == player
        end
      end
    end
  end
end
