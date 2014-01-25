require './app/entities'

module Controllers
  class Failure < StandardError
    attr_reader :errors, :status

    def initialize(errors, status)
      @errors = errors
      @status = status
    end
  end

  module Common
    extend ActiveSupport::Concern

    included do
      rescue_from Grape::Exceptions::ValidationErrors, ::Controllers::Failure do |e|
        errors = e.errors.each_with_object([]) do |(field, reason), errors|
          errors << { field: field, reason: Array.wrap(reason) }
        end
        Rack::Response.new(errors.to_json, e.status)
      end

      helpers Helpers
    end

    module Helpers
      def fail!(err, status)
        raise ::Controllers::Failure.new(err, status)
      end
    end
  end

  autoload :Registration, './app/controllers/registration'
  autoload :Session,      './app/controllers/session'
end
