require 'httparty'

module PaymentAPI
  class Apple
    def self.config
      env = ENV['RACK_ENV'] || 'app'
      @config ||= YAML.load_file('./config/apple.yml')[env]
    end

    include HTTParty

    logger LOGGER, :info

    base_uri config['uri']
    format :json

    attr_reader :provider

    def initialize(payload)
      @provider = 'apple'
      @receipt = payload['receipt']
    end

    def transaction_id
      transaction && transaction["receipt"]["in_app"][0]["original_transaction_id"]
    end

    def product_id
      transaction && transaction["receipt"]["in_app"][0]["product_id"]
    end

    private

    def transaction
      return @transaction unless @transaction.nil?
      response = self.class.post('/verifyReceipt', body: {'receipt-data' => @receipt}.to_json)

      if response.code == 200
        @transaction = response.parsed_response
        if @transaction['receipt']['bundle_id'] != self.class.config['bundle_id']
          @transaction = false
        end
      else
        @transaction = false
      end

      @transaction
    end
  end
end
