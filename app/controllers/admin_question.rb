module Controllers
  class AdminQuestion < Grape::API
    include Common

    version 'v1'
    format :json

    namespace :admin do
      params { requires :token, authentication_token: true }

      namespace :questions do
        desc "Create a new question"
        params do
          requires :question do
            requires :expires_at, type: Time
            requires :reveals_at, type: Time
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
            question.create_with(components)
            present question, with: Entities::Question, details: true
          rescue Domain::Error => err
            fail! err, 403
          end
        end

        desc "List the questions"
        get do
          questions = Domain::Question.dataset.ordered(:desc).all
          present questions, with: Entities::Question, admin: true
        end

        desc "Show a question"
        get ':id' do
          if question = Domain::Question.dataset.where(id: params[:id]).eager(:components).first
            present question, with: Entities::Question, admin: true, details: true
          else
            fail!(:not_found, 404)
          end
        end

        desc "Answer a question"
        params do
          requires :components, type: Hash
        end
        put ':id' do
          begin
            if question = Domain::Question.find_for_answer(params[:id])
              components = params[:components]
              question.validate_answers!(components) # This will raise error unless components are valid.
              Workers::QuestionAnswerer.perform_async(question.id, components)
            else
              fail!(:not_found, 404)
            end
          rescue Domain::Error => err
            fail! err, 403
          end
        end
      end
    end
  end
end
