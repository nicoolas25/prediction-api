module Controllers
  class Registration < Grape::API
    include Common

    version 'v1'
    format :json

    namespace :registrations do
      desc "Create a new user."
      params do
        requires :oauth2Provider, type: String, desc: "The oauth2 provider to use."
        requires :oauth2Token,    type: String, desc: "The oauth2 token for the provider."
        requires :nickname, type: String, desc: "The user's nickname."
      end
      post do
        player, api = Domain::Player.register(params[:oauth2Provider], params[:oauth2Token], params[:nickname])
        player.authenticate!(api)
        present player, with: Entities::Player, token: true, config: true
      end

      desc "Add a social account to an existing user."
      params do
        requires :oauth2Provider, type: String, desc: "The oauth2 provider to use."
        requires :oauth2Token,    type: String, desc: "The oauth2 token for the provider."
      end
      post :social do
        check_auth! # Ensure the user is authenticated
        begin
          player.update_social_association(params[:oauth2Provider], params[:oauth2Token])
          present player, with: Entities::Player, token: true
        rescue Domain::Error
          fail! $!, 403
        end
      end
    end
  end
end
