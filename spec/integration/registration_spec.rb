require './spec/spec_helper'

describe Controllers::Registration do
  def app
    Controllers::Registration
  end

  describe "POST /v1/registrations" do
    describe "with a valid provider / token pair" do
      subject { post "/v1/registrations", {nickname: 'nickname', oauth2Provider: 'facebook', oauth2Token: 'test-token'} }
      before  { mock_social_id('facebook') }

      it "creates a new user" do
        expect{subject}.to change{Domain::Player.count}.by(1)
      end

      it "returns a 201 status code" do
        subject
        expect(last_response.status).to eql(201)
      end

      it "returns a JSON object containing user informations" do
        subject
        json = JSON.parse(last_response.body)
        expect(json['token']).to eql(Domain::Player.last.token)
      end

      it "authenticates the user" do
        subject
        expect(Domain::Player.last.token_expiration).to be > Time.now
      end
    end
  end

  after :each do
    Domain::Player.where(nickname: 'nickname').destroy
  end
end
