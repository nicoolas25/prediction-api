require './spec/spec_helper'

describe Domain::QuestionComponentChoice do
  describe "#confirms?(answer)" do
    subject { component.confirms?(answer) }

    let(:component){ Domain::QuestionComponentChoice.new(valid_answer: 'foo') }

    describe "when the answer's value and the component's valid_answer are the same" do
      let(:answer){ double('PredictionAnswerChoice', value: 'foo') }

      it { should eql(true) }
    end

    describe "when the answer's value and the component's valid_answer arn't the same" do
      let(:answer){ double('PredictionAnswerChoice', value: 'bar') }

      it { should eql(false) }
    end
  end
end

describe Domain::QuestionComponentClosest do
  describe "#confirms?(answer)" do
    subject { component.confirms?(answer) }

    let(:component){ Domain::QuestionComponentClosest.new(valid_answer: 10.0, answers: answers) }
    let(:answers){ Array.new(5){ |i| double('PredictionAnswerClosest', diff: i.to_f) } }

    describe "when the answer's value is the closest from the component's valid_answer" do
      let(:answer){ answers.first }

      it { should eql(true) }
    end

    describe "when there is another answer's value that are striclty closer to the component's valid_answer" do
      let(:answer){ answers.last }

      it { should eql(false) }
    end
  end

end

describe Domain::QuestionComponentExact do
  describe "#confirms?(answer)" do
    subject { component.confirms?(answer) }

    let(:component){ Domain::QuestionComponentExact.new(valid_answer: 10.0) }

    describe "when the answer's value and the component's valid_answer are the same" do
      let(:answer){ double('PredictionAnswerExact', value: 10.0) }

      it { should eql(true) }
    end

    describe "when the answer's value and the component's valid_answer arn't the same" do
      let(:answer){ double('PredictionAnswerExact', value: 6.0) }

      it { should eql(false) }
    end
  end
end
