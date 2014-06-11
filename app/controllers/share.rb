module Controllers
  class Share < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :shares do
      namespace ':locale' do
        before { @locale = params[:locale] == 'ru' ? :en : params[:locale].to_sym }

        desc "Share something via a given social network"
        params do
          requires :locale, type: String, regexp: /^(fr)|(en)|(pt)|(es)|(ru)$/
          requires :kind, type: String, regexp: /^(participation)|(application)|(badge)$/
          optional :oauth2TokenFacebook, type: String
          optional :oauth2TokenTwitter, type: String
          optional :oauth2TokenGooglePlus, type: String
        end
        post ':kind/:id' do
          player.update_social_association_tokens(mapping_provider_tokens)
          sharing_service = ::Domain::Services::Sharing.new(player)
          shares = sharing_service.share(params[:kind], @locale, params[:id])
          fail!(sharing_service.error, 403) unless shares
          { cristals: player.reload.cristals, shares: shares }
        end
      end
    end
  end
end
