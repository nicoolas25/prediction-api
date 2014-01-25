module Controllers
  class Session < Grape::API
    include Common

    version 'v1'
    format :json

    desc "Open a new session."
    params do
      requires :oauth2Provider, type: String, desc: "The oauth2 provider to use."
      requires :oauth2Token, type: String, desc: "The oauth2 token for the provider."
    end
    post '/sessions' do
      player, err = Collections::Players.find_by_social(
        params[:oauth2Provider],
        params[:oauth2Token])
      if err
        fail! err, 401
      else
        Collections::Players.authenticate!(player)
        present player, with: Entities::Player, token: true
      end
    end
  end
end
