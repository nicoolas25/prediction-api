require 'httparty'

module PaymentAPI
  class Apple
    BUNDLE_ID = 'com.garbage.PredictionWC'.freeze

    include HTTParty

    logger LOGGER, :info

    # TODO: Pass this in production mode
    # base_uri (ENV['RACK_ENV'] == 'production' ? 'https://buy.itunes.apple.com' : 'https://sandbox.itunes.apple.com')

    base_uri 'https://sandbox.itunes.apple.com'
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
        if @transaction['receipt']['bundle_id'] != BUNDLE_ID
          @transaction = false
        end
      else
        @transaction = false
      end

      @transaction
    end
  end
end
