module Entities
  class Match < Grape::Entity
    include Common

    expose :event_at do |o, opts|
      o[:event_at].to_i
    end

    expose :tags, if: :match_service do |o, opts|
      tag_ids = o[:tags].split(',')
      opts[:match_service].tags(tag_ids).map{ |tag| Tag.new(tag) }
    end
  end
end
