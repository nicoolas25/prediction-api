module Controllers
  class Ladder < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :ladders do
      desc "List all the users ordered by the number of cristals they won"
      get :global do
        ranking_service = Domain::Services::Ranking.new
        players = ranking_service.players
        present players, with: Entities::Ladder, ranking_service: ranking_service
      end
    end
  end
end
