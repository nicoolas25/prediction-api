module Controllers
  class Admin < Grape::API
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
            present question, with: Entities::Question, details: true
          rescue Domain::Error => err
            fail! err, 403
          end
        end

        desc "List the questions"
        get do
          questions = Domain::Question.dataset.eager(:components).all
          present questions, with: Entities::Question, admin: true
        end
      end
    end
  end
end
