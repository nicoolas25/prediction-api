module Controllers
  class Ladder < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :ladders do
      desc "List all the users ordered by the number of cristals they won (only friends)"
      get :friends do
        ranking_service = Domain::Services::Ranking.new
        players = ranking_service.friends(player)
        present players, with: Entities::Ladder, ranking_service: ranking_service
      end

      desc "List the users ordered by the number of cristals they won (top of the ranking)"
      get 'global/top' do
        ranking_service = Domain::Services::Ranking.top
        players = ranking_service.players
        present players, with: Entities::Ladder, ranking_service: ranking_service
      end

      namespace 'global/:uid' do
        params { requires :uid, type: String }
        before { @user = params[:uid] == 'me' ? player : Domain::Player.first!(id: params[:uid]) }

        desc "List the users ordered by the number of cristals they won (after the selected user)"
        get :after do
          ranking_service = Domain::Services::Ranking.after(@user)
          players = ranking_service.players
          present players, with: Entities::Ladder, ranking_service: ranking_service
        end

        desc "List the users ordered by the number of cristals they won (before the selected user)"
        get :before do
          ranking_service = Domain::Services::Ranking.before(@user)
          players = ranking_service.players
          present players, with: Entities::Ladder, ranking_service: ranking_service
        end

        desc "List the users ordered by the number of cristals they won (arround the selected user)"
        get do
          ranking_service = Domain::Services::Ranking.arround(@user)
          players = ranking_service.players
          present players, with: Entities::Ladder, ranking_service: ranking_service
        end
      end
    end
  end
end
