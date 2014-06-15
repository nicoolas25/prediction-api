module Controllers
  class Match < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    desc "List the next matches"
    get :matches do
      match_service = Domain::Services::Match.new
      present Domain::Match.all(player), with: Entities::Match, match_service: match_service
    end
  end
end
