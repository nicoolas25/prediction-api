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
      locale = params[:locale].to_sym
      questions = Domain::Question.global.open.with_locale(locale).all
      present questions, with: Entities::Question, type: :list, locale: locale
    end
  end
end
