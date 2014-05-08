module Controllers
  class Bonus < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :bonus do
      namespace ':uid' do
        params { requires :uid, type: String }
        before { @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid]) }

        desc "List the user's bonus"
        get do
          bonuses = @user.distinct_bonuses
          bonus_service = Domain::Services::Bonus.new(@user)
          present bonuses, with: Entities::Bonus, bonus_service: bonus_service
        end
      end
    end
  end
end
