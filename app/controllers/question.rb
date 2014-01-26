module Controllers
  class Question < Grape::API
    include Common

    version 'v1'
    format :json

    before do
      check_auth!
    end

    desc "List all the questions"
    params do
      requires :locale, type: String, regexp: /^(fr)|(en)$/
    end
    get '/questions/:locale/global/open' do
      questions = Domain::Question.where(author_id: nil).all
      present questions, with: Entities::Question, type: :list
    end
  end
end
