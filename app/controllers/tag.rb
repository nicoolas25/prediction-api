module Controllers
  class Tag < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :tags do
      desc "List the tags"
      get do
        tag_service = Domain::Services::Tag.new(player)
        present Domain::Tag.all, with: Entities::Tag, tag_service: tag_service
      end
    end
  end
end
