module Controllers
  class AdminPlayer < Grape::API
    include Common

    version 'v1'
    format :json

    namespace :admin do
      params { requires :token, authentication_token: true }

      namespace :players do
        desc "List the players"
        get do
          players = Domain::Player.dataset.order(:id).all
          present players, with: Entities::Player, admin: true
        end

        desc "Detailled view of a specific player"
        get ':nickname' do
          if player = Domain::Player.where(nickname: params[:nickname]).first
            present player, with: Entities::Player, admin: true, details: true
          else
            fail!(:not_found, 404)
          end
        end

        desc "Update player attributes"
        params do
          optional :cristals, type: Integer
          optional :merge_target, type: String
        end
        put ':nickname' do
          if player = Domain::Player.where(nickname: params[:nickname]).first
            # Update cristals
            if cristals = params[:cristals]
              player.update(cristals: cristals)
            end

            # Merge players
            if (target = params[:merge_target]) && !target.blank?
              target = Domain::Player.first!(nickname: target)
              player.absorb!(target)
            end
          else
            fail!(:not_found, 404)
          end
        end
      end
    end
  end
end
