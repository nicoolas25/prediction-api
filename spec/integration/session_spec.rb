require './spec/spec_helper'

describe Controllers::Session do
  def app
    Controllers::Session
  end

  before :all do
    @player = Domain::Player.create(nickname: 'nickname')
    @player.add_social_association(provider: SocialAPI::PROVIDERS.index('facebook'), token: 'test-token', id: 'test-id')
  end

  before :each do
    @player.expire_token!
    @player.save
  end

  describe "POST /v1/sessions" do
    describe "with a valid credentials" do
      subject { post "/v1/sessions", {oauth2Provider: 'facebook', oauth2Token: 'test-token'} }
      before  { mock_social_id('facebook', 'test-id') }

      it "authenticates the user" do
        subject
        expect(Domain::Player.last.token_expiration).to be > Time.now
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
    end
  end

  after :all do
    Domain::Player.last.destroy
  end
end
