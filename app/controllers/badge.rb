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

        namespace ':identifier/:level' do
          params do
            requires :identifier, type: String
            requires :level, type: Integer
          end

          desc "Show the details of an user badge"
          get do
            badge = player.badges_dataset.for(params[:identifier]).level(params[:level]).first
            if badge
              present badge, with: Entities::Badge
            else
              fail! :badge_not_found, 404
            end
          end

          desc "Claim the bonus or cristals from a badge"
          params do
            requires :convert_to, type: String
          end
          post do
            begin
              badge = player.badges_dataset.for(params[:identifier]).level(params[:level]).first
              if badge
                badge.claim!(params[:convert_to])
                present badge, with: Entities::Badge
              else
                fail! :badge_not_found, 404
              end
            rescue Domain::Error
              fail! $!, 403
            end
          end
        end
      end
    end
  end
end
