module Controllers
  class Question < Grape::API
    include Common

    version 'v1'
    format :json

    before do
      check_auth!
    end

    desc "List all the questions"
    post '/questions' do
      {}
    end
  end
end
