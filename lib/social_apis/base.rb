module SocialAPI
  class Base
    def initialize(provider, token, social_id)
      @provider  = provider
      @token     = token
      @social_id = social_id
    end

    def provider_id
      SocialAPI::PROVIDERS.index(@provider)
    end

    def valid?
      !!social_id
    end
  end
end
