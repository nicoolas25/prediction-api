module Controllers
  class Activity < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :activities do
      namespace ':locale' do
        params { requires :locale, type: String, regexp: /^(fr)|(en)$/ }
        before { @locale = params[:locale].to_sym }

        desc "List last events for the registered user"
        params do
          optional :before, type: Time
          optional :after, type: Time
        end
        get do
          event_services = ::Domain::Services::Event.new(player, params[:before], params[:after])
          present event_services, with: Entities::Activity, locale: @locale
        end
      end
    end
  end
end
