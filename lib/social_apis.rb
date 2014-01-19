module SocialAPI
  # Do not reorder this!
  PROVIDERS = %w(facebook googleplus twitter).freeze

  autoload :Base,       './lib/social_apis/base'
  autoload :Facebook,   './lib/social_apis/facebook'
  autoload :GooglePlus, './lib/social_apis/google_plus'
  autoload :Twitter,    './lib/social_apis/twitter'

  def self.for(provider, token)
    case provider
    when 'facebook'   then Facebook.new(provider, token)
    when 'googleplus' then GooglePlus.new(provider, token)
    when 'twitter'    then Twitter.new(provider, token)
    else nil
    end
  end
end
