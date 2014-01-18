require './spec/spec_helper'

describe Domain::PredictionAnswer do
  describe "#right?" do
    subject { answer.right? }

    let(:answer){ Domain::PredictionAnswer.new(target: target) }

    describe "when the targeted QuestionComponent confirms the answer" do
      let(:target){ double('QuestionComponent', confirms?: true) }

      it { should eql(true) }
    end

    describe "when the targeted QuestionComponent doesn't confirm the answer" do
      let(:target){ double('QuestionComponent', confirms?: false) }

      it { should eql(false) }
    end
  end
end

describe Domain::PredictionAnswerClosest do
  describe "#diff" do
    subject { answer.diff }

    let(:answer){ Domain::PredictionAnswerClosest.new(target: target, value: 10.0) }
    let(:target){ double('QuestionComponentClosest', valid_answer: 6.0) }

    it "returns a positive value equal to the difference between the target's valid answer and the answer's value" do
      expect(subject).to eql(4.0)
    end
  end
end
