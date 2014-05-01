module Controllers
  class Payment < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :payments do
      namespace ':provider' do
        desc "Acknowledge an in-app purchase."
        params do
          requires :provider, type: String, regexp: /^(apple)|(google)$/
          requires :payload, type: Hash do
            optional :receipt, type: String
            optional :product_id, type: String
            optional :token, type: String
          end
        end
        post do
          provider = params[:provider]
          payload = params[:payload]
          purchase_service = ::Domain::Services::Purchase.new(player, provider, payload)
          purchase_service.apply!

          bonuses = player.bonuses_dataset.distinct(:identifier).all
          bonus_service = Domain::Services::Bonus.new(player)
          {
            cristals: player.cristals,
            bonus: present(bonuses, with: Entities::Bonus, bonus_service: bonus_service)
          }
        end
      end
    end
  end
end
