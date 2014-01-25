require './spec/spec_helper'

describe Domain::EarningService do
  describe "#earning_for" do
    subject { earning_service.earning_for(participation) }

    let(:question) { question = Domain::Question.new(participations: []) }
    let(:earning_service) { Domain::EarningService.new(question) }
    let(:participation) {
      predictions = (0..1).map{ Domain::Prediction.new(question: question) }

      100.times do
        participation = Domain::Participation.new(prediction: predictions[0], cristals: 100)
        question.participations << participation
      end
      # 10000 cristals on one side

      26.times do |i|
        participation = Domain::Participation.new(prediction: predictions[1], cristals: 25)
        question.participations << participation
      end
      # 650 cristals on another side side

      question.participations.last
    }

    it "gives the possible amount of cristals that could be earned with a participation" do
      should eql(409)
    end
  end
end
