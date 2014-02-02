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
      present questions, with: Entities::Question, locale: locale, player: player
    end

    desc "Show the details of a question"
    params do
      requires :locale, type: String, regexp: /^(fr)|(en)$/
      requires :id, type: String, regexp: /^\d+$/
    end
    get '/questions/:locale/:id' do
      locale = params[:locale].to_sym
      if question = Domain::Question.with_locale(locale).where(id: params[:id]).first
        present question, with: Entities::Question, locale: locale, details: true
      else
        fail!(:question_not_found , 404)
      end
    end
  end
end
