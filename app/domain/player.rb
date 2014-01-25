require 'securerandom'
require 'active_support/core_ext/numeric'

module Domain
  class Player
    include Common

    attr_accessor :id, :nickname, :first_name, :last_name, :social_associations, :friends, :token, :token_expiration

    def regenerate_token!
      self.token = SecureRandom.hex
      self.token_expiration = Time.now + 2.days
    end
  end
end
