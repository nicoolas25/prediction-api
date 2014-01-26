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
      begin
        player = Domain::Player.find_by_social_infos(params[:oauth2Provider], params[:oauth2Token])
        player.authenticate!
        present player, with: Entities::Player, token: true
      rescue Domain::Error
        fail! $!, 401
      end
    end
  end
end
