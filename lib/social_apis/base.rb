module SocialAPI
  class Base
    attr_reader :token

    def initialize(provider, token, social_id)
      @provider  = provider.kind_of?(Numeric) ? provider : SocialAPI::PROVIDERS.index(provider)
      @token     = token
      @social_id = social_id
    end

    def provider_id
      @provider
    end

    def provider_name
      SocialAPI.provider(@provider)
    end

    def symetric_friends?
      SocialAPI::SYMETRIC_FRIENDSHIP_PROVIDERS.include?(@provider)
    end

    def valid?(force_refetch=false)
      if force_refetch
        social_id_was = social_id
        @social_id = nil
        if social_id != social_id_was
          @social_id = social_id_was
          return false
        end
      end
      !!social_id
    end
  end
end
