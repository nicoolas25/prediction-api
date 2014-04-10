module Controllers
  class Badge < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :badges do
      namespace ':uid' do
        params { requires :uid, type: String }
        before {
          @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid])
          @mine = @user == player
        }

        desc "List the user's badges"
        get do
          visible_badges = @user.badges_dataset.visible.all
          present visible_badges, with: Entities::Badge
        end

        desc "Show the details of an user badge"
        params do
          requires :identifier, type: String
          requires :level, type: Integer
        end
        get ':identifier/:level' do
          badge = player.badges_dataset.
            where(identifier: params[:identifier], level: params[:level]).
            first
          fail! :badge_not_found, 404 unless badge
          present badge, with: Entities::Badge
        end
      end
    end
  end
end
