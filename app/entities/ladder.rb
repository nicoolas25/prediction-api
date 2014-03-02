module Entities
  class Ladder < Grape::Entity
    include Common

    expose :id

    expose :nickname

    expose :score, if: :ranking_service do |l, opts|
      opts[:ranking_service].score_for(l)
    end

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }
  end
end
