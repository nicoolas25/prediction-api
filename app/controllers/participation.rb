module Controllers
  class Participation < Grape::API
    include Common

    version 'v1'
    format :json

    before do
      check_auth!
    end

    desc "Participate to a question"
    params do
      requires :id, type: String, regexp: /^\d+$/
    end
    post '/participations' do
      begin
        question = Domain::Question.dataset.open.where(id: params[:id]).eager(:components).first
        fail!(:question_not_found_or_expired , 404) unless question

        stakes = params[:stakes].to_i
        componnents = params[:componnents]
        participation = player.participate_to!(question, stakes, componnents)

        present participation, with: Participation
      rescue Domain::Error
        fail! $!, 403
      end
    end
  end
end
