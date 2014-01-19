module Controllers
  class Registration < Grape::API
    version 'v1'
    format :json

    desc "Create a new user."
    params do
      requires :nickname, type: String, desc: "The user's nickname."
      requires :oauth2Provider, type: String, desc: "The oauth2 provider to use."
      requires :oauth2Token, type: String, desc: "The oauth2 token for the provider."
    end
    post '/registrations' do
      player, err = Collections::Players.create(
        params[:oauth2Provider],
        params[:oauth2Token],
        params[:nickname])
      if err
        error! err, 403
      else
        present player, with: Entities::Player, token: true
      end
    end
  end
end
