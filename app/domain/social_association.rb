module Domain
  class SocialAssociation
    include Common

    attr_accessor :provider, :player, :id, :token
  end
end
