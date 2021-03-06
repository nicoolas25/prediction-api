module Entities
  class Ladder < Grape::Entity
    include Common

    expose :id

    expose :nickname

    expose :delta, if: :ranking_service do |l, opts|
      opts[:ranking_service].delta_for(l)
    end

    expose :rank, if: :ranking_service do |l, opts|
      opts[:ranking_service].rank_for(l)
    end

    expose :score, if: :ranking_service do |l, opts|
      opts[:ranking_service].score_for(l)
    end

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }
  end
end
