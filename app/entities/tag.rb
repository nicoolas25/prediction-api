module Entities
  class Tag < Grape::Entity
    include Common

    expose :keyword

    expose :questions_count, if: :tag_service do |t, opts|
      opts[:tag_service].question_count(t)
    end
  end
end


