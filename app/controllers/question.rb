module Controllers
  class Question < Grape::API
    include Common

    version 'v1'
    format :json

    namespace :questions do
      desc "Create a new question"
      params do
        requires :token, authentication_token: true
        requires :question do
          requires :expires_at, type: Time
          requires :labels, type: Hash
          requires :components, type: Array
        end
      end
      post do
        begin
          question_params = params[:question]
          components_params = question_params.delete(:components)
          components = Domain::QuestionComponent.build_many(components_params)
          question = Domain::Question.build(question_params)
          question.create_with_components(components)

          if question.id
            present question, with: Entities::Question, details: true
          else
            fail!(:not_saved, 403)
          end
        rescue Domain::Error => err
          fail! err, 403
        end
      end

      namespace ':locale' do
        params { requires :locale, type: String, regexp: /^(fr)|(en)$/ }
        before { check_auth! }
        before { @locale = params[:locale].to_sym }

        desc "List the open questions for a player"
        get 'global/open' do
          questions = Domain::Question.global.open_for(player).with_locale(@locale).all
          present questions, with: Entities::Question, locale: @locale
        end

        desc "List the answered questions of a player"
        get 'global/answered' do
          questions = Domain::Question.global.answered_by(player).with_locale(@locale).all
          present questions, with: Entities::Question, locale: @locale
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
