module Controllers
  class Question < Grape::API
    include Common

    version 'v1'
    format :json

    before do
      check_auth!
    end

    namespace :questions do
      namespace ':locale' do
        params { requires :locale, type: String, regexp: /^(fr)|(en)$/ }
        before { @locale = params[:locale].to_sym }

        desc "List the open questions for a player"
        get 'global/open' do
          questions = Domain::Question.global.open_for(player).with_locale(@locale).all
          present questions, with: Entities::Question, locale: @locale, player: player
        end

        desc "List the answered questions of a player"
        get 'global/answered' do
          questions = Domain::Question.global.answered_by(player).with_locale(@locale).all
          present questions, with: Entities::Question, locale: @locale, player: player
        end

        desc "Show the details of a question"
        params do
          requires :id, type: String, regexp: /^\d+$/
        end
        get ':id' do
          if question = Domain::Question.with_locale(@locale).where(id: params[:id]).first
            present question, with: Entities::Question, locale: @locale, details: true
          else
            fail!(:question_not_found , 404)
          end
        end
      end
    end
  end
end
