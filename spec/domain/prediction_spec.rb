require './app/domain'

describe Domain::Prediction do
  describe "#right?" do
    subject { prediction.right? }

    let(:prediction){ Domain::Prediction.new(answers: answers) }

    describe "when each of the answers are right" do
      let(:answers){ Array.new(2){ double('Answer', right?: true) } }

      it { should eql(true) }
    end

    describe "when one of it's answer isn't right" do
      let(:answers){ Array.new(2){ |i| double('Answer', right?: i == 1) } }

      it { should eql(false) }
    end
  end
end
