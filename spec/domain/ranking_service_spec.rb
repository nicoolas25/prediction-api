require './spec/spec_helper'

describe Domain::RankingService do
  let(:participations){ Array.new(5){ |i| double(player: "player_#{i % 3}", earnings: i * 10) } }
  let(:expected_result){ {"player_0" => 30, "player_1" => 50, "player_2" => 20} }

  describe "#rank" do
    subject { ranking_service.rank }

    before do
      @klass = double(
        all: participations,
        tagged_with: participations,
        around_player: participations,
        around_player_and_tagged_with: participations)
      stub_const('Collections::Participations', @klass)
    end

    describe "with the 'tag' option" do
      let(:ranking_service){ Domain::RankingService.new(tag: 'foo') }

      it "uses the Collections::Participations#tagged_with as reference" do
        expect(@klass).to receive(:tagged_with).with('foo')
        subject
      end

      it "returns a Hash with players as keys and total earnings" do
        expect(subject).to eql(expected_result)
      end
    end

    describe "with the 'firends_of' option" do
      let(:ranking_service){ Domain::RankingService.new(friends_of: 'player_0') }

      it "uses the Collections::Participations#around_player as reference" do
        expect(@klass).to receive(:around_player).with('player_0')
        subject
      end

      it "returns a Hash with players as keys and total earnings" do
        expect(subject).to eql(expected_result)
      end
    end

    describe "with the 'tag' ans the 'friends_of' options" do
      let(:ranking_service){ Domain::RankingService.new(friends_of: 'player_0', tag: 'foo') }

      it "uses the Collections::Participations#around_player as reference" do
        expect(@klass).to receive(:around_player_and_tagged_with).with('player_0', 'foo')
        subject
      end

      it "returns a Hash with players as keys and total earnings" do
        expect(subject).to eql(expected_result)
      end
    end

    describe "with no options" do
      let(:ranking_service){ Domain::RankingService.new }

      it "uses the Collections::Participations#around_player as reference" do
        expect(@klass).to receive(:all)
        subject
      end

      it "returns a Hash with players as keys and total earnings" do
        expect(subject).to eql(expected_result)
      end
    end
  end
end
