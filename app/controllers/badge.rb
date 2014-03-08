module Controllers
  class Badge < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    desc "List the user's badges"
    get :badges do
      visible_badges = player.badges.select(&:visible?)
      present visible_badges, with: Entities::Badge
    end
  end
end
