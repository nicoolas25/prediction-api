module SocialAPI
  class Base
    def initialize(provider, token)
      @provider = provider
      @token = token
    end

    def provider_id
      SocialAPI::PROVIDERS.index(@provider)
    end

    def valid?
      !!get_social_id
    end
  end
end
