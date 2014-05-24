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
          requires :question, type: Hash do
            requires :expires_at, type: Time
            requires :reveals_at, type: Time
            optional :event_at,   type: Time
            requires :labels,     type: Hash
            requires :components, type: Array
          end
        end
        post do
          question_params = params[:question]
          components_params = question_params.delete(:components)
          components = Domain::QuestionComponent.build_many(components_params)
          question = Domain::Question.new(question_params)
          question.create_with(components)
          present question, with: Entities::Question, details: true
        end

        desc "List the questions"
        get do
          questions = Domain::Question.dataset.ordered(:desc).all
          present questions, with: Entities::Question, admin: true
        end

        namespace ':id' do
          params do
            requires :id, type: Integer
          end

          desc "Show a question"
          get do
            if question = Domain::Question.dataset.where(id: params[:id]).eager(:components).first
              present question, with: Entities::Question, admin: true, details: true
            else
              fail!(:not_found, 404)
            end
          end

          desc "Update a question"
          params do
            requires :question, type: Hash do
              requires :expires_at, type: Time
              requires :reveals_at, type: Time
              optional :event_at,   type: Time
              requires :labels,     type: Hash
              requires :components, type: Array
            end
          end
          put do
            question = Domain::Question.find_for_update(params[:id])
            question_params = params[:question]
            components_params = question_params.delete(:components)
            question.set(question_params.merge(pending: false))
            question.update_components(components_params)
            present question, with: Entities::Question, details: true
          end

          desc "Answer a question"
          params do
            requires :components, type: Hash
          end
          put 'answer' do
            if question = Domain::Question.find_for_answer(params[:id])
              components = params[:components]
              question.validate_answers!(components) # This will raise error unless components are valid.
              Workers::QuestionAnswerer.perform_async(question.id, components)
            else
              fail!(:not_found, 404)
            end
          end
        end
      end
    end
  end
end
