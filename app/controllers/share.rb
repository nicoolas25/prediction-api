module Controllers
  class Share < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :shares do
      namespace ':locale' do
        params { requires :locale, type: String, regexp: /^(fr)|(en)$/ }
        before { @locale = params[:locale].to_sym }

        namespace ':provider' do
          params { requires :provider, type: String, regexp: /^(facebook)|(googleplus)$/ }

          desc "Share something via a given social network"
          params do
            requires :kind, type: String, regexp: /^(participation)|(application)|(badge)$/
            requires :oauth2Token, type: String, desc: "The oauth2 token for the provider."
          end
          post ':kind/:id' do
            sharing_service = ::Domain::Services::Sharing.new(player, params[:provider])
            sharing_service.update_social_association_token(params[:oauth2Token])
            fail!(sharing_service.error, 403) unless sharing_service.ready?

            shared = sharing_service.share!(params[:kind], @locale, params[:id])
            fail!(:not_shared, 403) unless shared
          end
        end
      end
    end
  end
end
