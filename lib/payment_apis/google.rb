module PaymentAPI
  class Google
    PACKAGE_NAME = 'com.gc.pulpo'.freeze

    attr_reader :provider

    def initialize(payload)
      @provider = 'google'
      @product_id = payload['product_id']
      @token = payload['token']
    end

    def transaction_id
      transaction && @token
    end

    def product_id
      tranasaction && @product_id
    end

    private

    def transaction
      # TODO: Call the google API (check the purchase state)
      nil
    end
  end
end
