module Controllers
  class Question < Grape::API
    include Common

    version 'v1'
    format :json

    before { check_auth! }

    namespace :questions do
      namespace ':locale' do
        params { requires :locale, type: String, regexp: /^(fr)|(en)$/ }
        before { @locale = params[:locale].to_sym }

        desc "List the open questions for a player"
        get 'global/open' do
          questions = Domain::Question.global.open.for(player).with_locale(@locale).ordered.all
          friend_service = Domain::Services::Friend.new(player, questions.map(&:id))
          present questions,
            with: Entities::Question,
            locale: @locale,
            friend_service: friend_service,
            made_prediction: false
        end

        desc "List the answered questions of a player"
        get 'global/answered' do
          questions = Domain::Question.global.open.answered_by(player).with_locale(@locale).ordered.all
          question_ids = questions.map(&:id)
          friend_service = Domain::Services::Friend.new(player, question_ids)
          winning_service = Domain::Services::Winning.new(player, question_ids)
          sharing_service = Domain::Services::SharingQuestion.new(player, question_ids)
          present questions,
            with: Entities::Question,
            locale: @locale,
            friend_service: friend_service,
            winning_service: winning_service,
            sharing_service: sharing_service,
            made_prediction: true
        end

        desc "List the answered questions of a player"
        get 'global/outdated' do
          questions = Domain::Question.global.expired.answered_by(player).with_locale(@locale).ordered(:desc).all
          question_ids = questions.map(&:id)
          friend_service = Domain::Services::Friend.new(player, question_ids)
          winning_service = Domain::Services::Winning.new(player, question_ids)
          sharing_service = Domain::Services::SharingQuestion.new(player, question_ids)
          present questions,
            with: Entities::Question,
            locale: @locale,
            friend_service: friend_service,
            winning_service: winning_service,
            sharing_service: sharing_service,
            made_prediction: true
        end

        desc "List the open questions for a player where a friend participate"
        get 'friends/open' do
          questions = Domain::Question.global.open.for(player).answered_by_friends(player).with_locale(@locale).ordered.all
          friend_service = Domain::Services::Friend.new(player, questions.map(&:id))
          present questions,
            with: Entities::Question,
            locale: @locale,
            friend_service: friend_service,
            made_prediction: false
        end

        desc "Show the details of a question"
        params do
          requires :locale, type: String, regexp: /^(fr)|(en)$/
          requires :id, type: String, regexp: /^\d+$/
        end
        get ':id' do
          if question = Domain::Question.with_locale(@locale).where(id: params[:id]).first
            question_ids = [question.id]
            friend_service = Domain::Services::Friend.new(player, question_ids)
            winning_service = Domain::Services::Winning.new(player, question_ids)
            sharing_service = Domain::Services::SharingQuestion.new(player, question_ids)
            present question,
              with: Entities::Question,
              locale: @locale,
              friend_service: friend_service,
              winning_service: winning_service,
              sharing_service: sharing_service,
              details: true
          else
            fail!(:question_not_found , 404)
          end
        end
      end
    end
  end
end
