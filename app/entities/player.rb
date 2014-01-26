module Entities
  class Player < Grape::Entity
    format_with(:timestamp) { |dt| dt.to_i }

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :nickname
    expose :first_name
    expose :last_name

    expose :social_associations, using: SocialAssociation, as: :social

    expose :config, if: :config do |p, opts|
      defined?(APPLICATION_CONFIG) ? APPLICATION_CONFIG : nil
    end
  end
end
