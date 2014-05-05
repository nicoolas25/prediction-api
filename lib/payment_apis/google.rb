require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

module PaymentAPI
  class Google
    PACKAGE_NAME          = 'com.gc.pulpo'.freeze
    API_VERSION           = 'v1.1'.freeze
    CACHED_API_FILE       = "/tmp/androidpublished-#{API_VERSION}.cache".freeze
    PRIVATE_KEY_PATH      = './config/pulpo-sa.p12'.freeze
    SERVICE_ACCOUNT_EMAIL = '505056628314@developer.gserviceaccount.com'.freeze

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
      transaction && @product_id
    end

    private

    def transaction
      return @transaction unless @transaction.nil?

      # Ensure authorization
      self.class.api_client
      self.class.authorize!

      r = self.class.api_client.execute(
        api_method: self.class.api_publisher.inapppurchases.get,
        parameters: {
          packageName: PACKAGE_NAME,
          productId: @product_id,
          token: @token
        })

      if r.status == 200 && r.data.purchase_state == 0 && r.data.consumption_state == 1
        @transaction = @token
      else
        @transaction = nil
      end

      @transaction
    end

    class << self
      def api_client
        @api_client ||= ::Google::APIClient.new(
          :application_name => 'Prediction API',
          :application_version => '1.0.0')
      end

      def authorize!
        return if @last_auth && (@last_auth + 3.hours) > Time.now
        api_client.authorization = ::Signet::OAuth2::Client.new(
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          audience:             'https://accounts.google.com/o/oauth2/token',
          scope:                'https://www.googleapis.com/auth/androidpublisher',
          issuer:               SERVICE_ACCOUNT_EMAIL,
          signing_key:          ::Google::APIClient::KeyUtils.load_from_pkcs12(PRIVATE_KEY_PATH, 'notasecret'))
          api_client.authorization.fetch_access_token!
          @last_auth = Time.now
      end

      # This will persist the api definition accross reloads
      def api_publisher
        @api_publisher ||= begin
          api = nil
          if File.exists? CACHED_API_FILE
            File.open(CACHED_API_FILE) do |file|
              api = Marshal.load(file)
            end
          else
            api = api_client.discovered_api('androidpublisher', API_VERSION)
            File.open(CACHED_API_FILE, 'w') do |file|
              Marshal.dump(api, file)
            end
          end
          api
        end
      end
    end
  end
end
