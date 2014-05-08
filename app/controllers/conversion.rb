module Controllers
  class Conversion < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    desc "Ask for a cristal to bonus conversion."
    params do
      requires :target, type: String
    end
    post 'conversions' do
      conversion_service = ::Domain::Services::Conversion.new(player, params[:target])
      conversion_service.apply!
      bonus_service = Domain::Services::Bonus.new(player)
      present player, with: Entities::ConversionResult, bonus_service: bonus_service
    end
  end
end
