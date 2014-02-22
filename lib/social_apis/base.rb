module SocialAPI
  class Base
    def initialize(provider, token, social_id)
      @provider  = provider.kind_of?(Numeric) ? provider : SocialAPI::PROVIDERS.index(provider)
      @token     = token
      @social_id = social_id
    end

    def provider_id
      @provider
    end

    def symetric_friends?
      SocialAPI::SYMETRIC_FRIENDSHIP_PROVIDERS.include?(@provider)
    end

    def valid?
      !!social_id
    end
  end
end
