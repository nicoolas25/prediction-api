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
      rescue_from Grape::Exceptions::ValidationErrors do |e|
        errors = e.errors.each_with_object([]) { |(f, r), es| es << { field: f, reason: Array.wrap(r) } }
        Rack::Response.new({code: 'bad_parameters', details: errors}.to_json, e.status)
      end

      rescue_from ::Controllers::Failure do |e|
        Rack::Response.new({code: e.code}.to_json, e.status)
      end

      helpers Helpers
    end

    module Helpers
      def fail!(err, status)
        raise ::Controllers::Failure.new(err, status)
      end

      def player
        return @player if @__player

        token     = headers['Authentication-Token']
        @__player = true
        @player   = Domain::Player.where(token: token).where{ token_expiration > Time.now }.first
      end

      def check_auth!
        fail!(:unauthorized, 401) if player.nil?
      end
    end
  end

  autoload :Participation, './app/controllers/participation'
  autoload :Question,      './app/controllers/question'
  autoload :Registration,  './app/controllers/registration'
  autoload :Session,       './app/controllers/session'
end
