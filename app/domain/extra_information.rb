module Domain
  class ExtraInformation < ::Sequel::Model
    one_to_one :social_association
  end
end
