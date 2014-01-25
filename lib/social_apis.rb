module SocialAPI
  autoload :Base,       './lib/social_apis/base'
  autoload :Facebook,   './lib/social_apis/facebook'
  autoload :GooglePlus, './lib/social_apis/google_plus'
  autoload :Twitter,    './lib/social_apis/twitter'

  # Do not reorder this!
  PROVIDERS = %w(facebook googleplus twitter).freeze

  def self.for(provider, token, id=nil)
    case provider
    when 'facebook', 0   then Facebook.new(provider, token, id)
    when 'googleplus', 1 then GooglePlus.new(provider, token, id)
    when 'twitter', 2    then Twitter.new(provider, token, id)
    else nil
    end
  end

  def self.provider(integer)
    PROVIDERS[integer]
  end
end
