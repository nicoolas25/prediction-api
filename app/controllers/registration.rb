module Controllers
  class Registration < Grape::API
    include Common

    version 'v1'
    format :json

    desc "Create a new user."
    params do
      requires :nickname, type: String, desc: "The user's nickname."
      requires :oauth2Provider, type: String, desc: "The oauth2 provider to use."
      requires :oauth2Token, type: String, desc: "The oauth2 token for the provider."
    end
    post '/registrations' do
      begin
        player = Domain::Player.register(params[:oauth2Provider], params[:oauth2Token], params[:nickname])
        player.authenticate!
        present player, with: Entities::Player, token: true
      rescue Domain::Error
        fail! $!, 403
      end
    end
  end
end
