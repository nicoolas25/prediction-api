require './app/entities'

module Controllers
  module Common
    extend ActiveSupport::Concern

    included do
      rescue_from Grape::Exceptions::ValidationErrors do |e|
        Rack::Response.new({errors: e.errors.keys}.to_json, e.status)
      end

      helpers Helpers
    end

    module Helpers
      def fail!(err, status)
        error! format_errors(err), status
      end

      def format_errors(error_hash)
        {errors: error_hash.keys}
      end
    end
  end

  autoload :Registration, './app/controllers/registration'
  autoload :Session,      './app/controllers/session'
end
