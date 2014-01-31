require './spec/spec_helper'

describe Controllers::Registration do
  def app
    Controllers::Registration
  end

  before :all do
    Domain::Player.where(nickname: ['nickname', 'other_nickname']).destroy
  end

  describe "POST /v1/registrations" do
    describe "with an invalid provider" do
      subject { post "/v1/registrations", {nickname: 'nickname', oauth2Provider: 'facebok', oauth2Token: 'test-token'} }

      it "returns a 403 status code" do
        subject
        expect(last_response.status).to eql(403)
      end

      it "returns a JSON object containing a {'code':'invalid_oauth2_provider'}" do
        subject
        json = JSON.parse(last_response.body)
        expect(json['code']).to eql('invalid_oauth2_provider')
      end
    end

    describe "with an invalid token" do
      subject { post "/v1/registrations", {nickname: 'nickname', oauth2Provider: 'facebook', oauth2Token: 'invalid-test-token'} }
      before  { mock_social_id_miss('facebook') }

      it "returns a 403 status code" do
        subject
        expect(last_response.status).to eql(403)
      end

      it "returns a JSON object containing a {'code':'invalid_oauth2_token'}" do
        subject
        json = JSON.parse(last_response.body)
        expect(json['code']).to eql('invalid_oauth2_token')
      end
    end

    describe "with an already used nickname" do
      subject { post "/v1/registrations", {nickname: 'nickname', oauth2Provider: 'facebook', oauth2Token: 'test-token'} }
      before  { mock_social_id('facebook') }
      before  { Domain::Player.create(nickname: 'nickname') }

      it "returns a 403 status code" do
        subject
        expect(last_response.status).to eql(403)
      end

      it "returns a JSON object containing a {'code':'nickname_taken'}" do
        subject
        json = JSON.parse(last_response.body)
        expect(json['code']).to eql('nickname_taken')
      end
    end

    describe "with an already used token" do
      subject { post "/v1/registrations", {nickname: 'nickname', oauth2Provider: 'facebook', oauth2Token: 'test-token'} }
      before  { mock_social_id('facebook', 'test-id') }
      before do
        player = Domain::Player.create(nickname: 'other_nickname')
        player.add_social_association(provider: SocialAPI::PROVIDERS.index('facebook'), id: 'test-id', token: 'test-token-old')
      end

      it "returns a 403 status code" do
        subject
        expect(last_response.status).to eql(403)
      end

      it "returns a JSON object containing a {'code':'social_account_taken'}" do
        subject
        json = JSON.parse(last_response.body)
        expect(json['code']).to eql('social_account_taken')
      end
    end

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
    Domain::Player.where(nickname: ['nickname', 'other_nickname']).destroy
  end
end
