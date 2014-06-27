module Entities
  class Match < Grape::Entity
    include Common

    expose :event_at do |o, opts|
      o[:event_at].to_i
    end

    expose :tags, if: :match_service do |o, opts|
      tag_ids = o[:tags].split(',')
      # TODO: Do this on the client side
      opts[:match_service].tags(tag_ids).
        sort_by { |tag| tag.keyword.start_with?('c/') ? 1 : 0 }.
        map{ |tag| Tag.new(tag) }
    end

    expose :total do |o, opts|
      o[:total]
    end

    expose :remaining do |o, opts|
      o[:remaining]
    end
  end
end
