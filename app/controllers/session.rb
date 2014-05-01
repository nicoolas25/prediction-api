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
      player, api = Domain::Player.find_by_social_infos(params[:oauth2Provider], params[:oauth2Token])
      player.authenticate!(api)
      player.ask_for_cristals!
      present player, with: Entities::Player, token: true, config: true
    end

    desc "Ping the server to get cristals"
    get '/ping' do
      check_auth!
      player.ask_for_cristals!
      present player, with: Entities::Player, config: true
    end
  end
end
