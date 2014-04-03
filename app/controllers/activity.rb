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
          optional :before, type: Integer
          optional :after, type: Integer
        end
        get do
          before = params[:before].try{ |t| Time.at(t) }
          after = params[:after].try{ |t| Time.at(t) }
          event_service = ::Domain::Services::Event.new(player, before, after)
          present event_service.events,
            with: Entities::Activity,
            event_service: event_service,
            locale: @locale
        end
      end
    end
  end
end
