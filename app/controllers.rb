require 'grape'
require './lib/grape_validators'

require './app/workers'
require './app/entities'

module Controllers
  class Failure < StandardError
    attr_reader :code, :status

    def initialize(error, status)
      @code   = error.respond_to?(:message) ? error.message : error
      @status = status
    end
  end

  module Common
    extend ActiveSupport::Concern

    included do
      rescue_from :all do |exception|
        case exception
        when Grape::Exceptions::ValidationErrors
          errors = exception.errors.each_with_object([]) { |(f, r), es| es << { field: f, reason: Array.wrap(r) } }
          Rack::Response.new({code: 'bad_parameters', details: errors}.to_json, exception.status)
        when ::Controllers::Failure
          Rack::Response.new({code: exception.code}.to_json, exception.status)
        when ::Domain::Error
          LOGGER.error("Error: #{exception.message} code returned.")
          Rack::Response.new({code: exception.message}.to_json, exception.code)
        else
          if ENV['RACK_ENV'] == 'test'
            raise exception
          else
            LOGGER.error("Unexpected exception raised: #{exception}\n#{exception.backtrace.join("\n")}\n")
            Rack::Response.new({code: :unknown_error}.to_json, 500)
          end
        end
      end

      helpers Helpers

      logger LOGGER
    end

    module Helpers
      def fail!(err, status)
        raise ::Controllers::Failure.new(err, status)
      end

      def player
        return @player if @__player

        token     = headers['Authentication-Token']
        @__player = true
        @player   = token.present? && Domain::Player.where(token: token).where{ token_expiration > Time.now }.first
      end

      def check_auth!
        fail!(:unauthorized, 401) unless player
      end

      def mapping_provider_tokens
        { facebook: params[:oauth2TokenFacebook],
          twitter: params[:oauth2TokenTwitter],
          googleplus: params[:oauth2TokenGooglePlus] }
      end
    end
  end

  autoload :AdminQuestion, './app/controllers/admin_question'
  autoload :AdminPlayer,   './app/controllers/admin_player'

  autoload :Activity,      './app/controllers/activity'
  autoload :Badge,         './app/controllers/badge'
  autoload :Bonus,         './app/controllers/bonus'
  autoload :Conversion,    './app/controllers/conversion'
  autoload :Ladder,        './app/controllers/ladder'
  autoload :Match,         './app/controllers/match'
  autoload :Participation, './app/controllers/participation'
  autoload :Payment,       './app/controllers/payment'
  autoload :Question,      './app/controllers/question'
  autoload :Registration,  './app/controllers/registration'
  autoload :Session,       './app/controllers/session'
  autoload :Share,         './app/controllers/share'
  autoload :Tag,           './app/controllers/tag'
  autoload :User,          './app/controllers/user'
end
