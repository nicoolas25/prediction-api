module Domain
  class Question
    include Common

    attr_accessor :id, :labels, :tags, :components, :participations
  end
end
