module Domain
  class SocialAssociation < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player

    def validate
      super
      errors.add(:id, 'is already taken') if new? && SocialAssociation.where(provider: provider, id: id).count > 0
    end
  end
end
