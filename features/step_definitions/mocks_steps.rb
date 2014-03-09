DEFAULT_CRISTALS = 20

# Fake the provider response for friends
def fake_friends(provider, friend_ids=[])
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = { friend_ids: friend_ids }
  allow_any_instance_of(klass).to receive_messages(messages)
end

def fake_social_id(provider, social_id=nil)
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = { social_id: social_id, first_name: 'John', last_name: 'Do' }
  allow_any_instance_of(klass).to receive_messages(messages)
end

Given /^I have (a valid|an invalid) OAuth2 token for the "([^"]*)" provider(?: which returns the id "([^"]*)")?$/ do |valid, provider, id|
  social_id = (valid == 'a valid') && (id || SecureRandom.hex)
  fake_social_id(provider, social_id)
  fake_friends(provider)
end

Given /^an user "([^"]*)" is already registered$/ do |nickname|
  Domain::Player.create(nickname: nickname, cristals: DEFAULT_CRISTALS)
end

Given /^"(\d+)" registered users with "([^"]*)" as nickname prefix$/ do |size, prefix|
  (0...size.to_i).each do |index|
    Domain::Player.create(nickname: "#{prefix}_#{index}", cristals: DEFAULT_CRISTALS)
  end
end

Given /^the user "([^"]*)" have "(\d+)" cristals$/ do |nickname, cristals|
  player = Domain::Player.first!(nickname: nickname)
  player.update(cristals: cristals.to_i)
end

Given /^the user "([^"]*)" have a valid token(?:: "([^"]*))?"$/ do |nickname, token|
  player = Domain::Player.first!(nickname: nickname)
  player.token = token.presence || SecureRandom.hex
  player.token_expiration = Time.now + 1.day
  player.save
end

Given /^a social account for "([^"]*)"  with "([^"]*)" id is linked to "([^"]*)"$/ do |provider, id, nickname|
  fake_friends(provider)
  player = Domain::Player.first!(nickname: nickname)
  provider_id = SocialAPI::PROVIDERS.index(provider)
  player.add_social_association(provider: provider_id, id: id, token: 'dont-care')
end

Given /^I am an authenticated user(?:: "([^"]*)")?(?: with "(\d+)" cristals)?$/ do |nickname, cristals|
  nickname ||= "nickname"
  cristals ||= DEFAULT_CRISTALS
  steps %Q{
    Given an user "#{nickname}" is already registered
    And the user "#{nickname}" have a valid token: "12345"
    And the user "#{nickname}" have "#{cristals}" cristals
    And I set headers:
      | Authentication-Token | 12345 |
  }
end

Given /^existing (expired )?questions:$/ do |expired, questions|
  questions.rows_hash.each do |id, label|
    attrs = {id: id.to_i, label_fr: label}
    attrs[:expires_at] = expired.present? ? (Time.now - 1.day) : (Time.now + 1.day)
    Domain::Question.create(attrs)
  end
end

Given /^existing components for the question "([^"]*)":$/ do |question_id, components|
  components.raw.each_with_index do |(id, kind, label, *extra), position|
    attrs = {}
    attrs[:id] = id.to_i
    attrs[:kind] = Domain::QuestionComponent::KINDS.index(kind)
    attrs[:position] = position
    attrs[:label_fr] = label
    attrs[:choices_fr] = (kind == 'choices') ? extra.shift : nil
    attrs[:question_id] = question_id
    attrs[:valid_answer] = extra.shift.try(:to_f)
    Domain::QuestionComponent.create(attrs)
  end
end

Given /^the user "([^"]*)" has answered the question "([^"]*)"(?: staking "(\d+)")? with:$/ do |nickname, question_id, stakes, answers|
  stakes = stakes.try(&:to_i) || 10
  player = Domain::Player.first!(nickname: nickname)
  question = Domain::Question.first!(id: question_id)
  raw_answers = answers.hashes
  player.participate_to!(question, stakes, raw_answers)
end

Given /^an application configuration with "([^"]*)" set to "([^"]*)"$/ do |path, value|
  value = value.to_i if value =~ /\d+/
  @app_config ||= {}
  path = path.split('.').map(&:to_sym)
  name = path.pop
  path.reduce(@app_config){|hash, segment| hash[segment] ||= {} }[name] = value
  stub_const('APPLICATION_CONFIG', @app_config)
end

Given /^there is the following participations for the question "([^"]*)":$/ do |question_id, participations|
  question = Domain::Question.first!(id: question_id)
  participations.raw.each do |nickname, stakes, cksum|
    player = Domain::Player.first!(nickname: nickname)
    prediction = Domain::Prediction.first_or_create_from_cksum(cksum, question)
    Domain::Participation.create(player: player, question: question, prediction: prediction, stakes: stakes)
  end
end

Given /^there are already registered players via "([^"]*)" friends to the id "([^"]*)":$/ do |provider, social_id, friends|
  provider_id = SocialAPI::PROVIDERS.index(provider)

  # Create the players and their social associations
  fake_friends(provider, [])
  friends.raw.map do |nickname, friend_social_id|
    player = Domain::Player.create(nickname: nickname, cristals: DEFAULT_CRISTALS)
    player.add_social_association(provider: provider_id, id: friend_social_id, token: 'not-revelent')
  end

  fake_friends(provider, friends.raw.map(&:last))
end

Given /^the user "([^"]*)" have the following "([^"]*)" friends:$/ do |nickname, provider, friends|
  provider_id = SocialAPI::PROVIDERS.index(provider)
  player = Domain::Player.first!(nickname: nickname)
  friends.raw.map do |nickname|
    friend = Domain::Player.first!(nickname: nickname)
    DB[:friendships].insert(provider: provider_id, left_id: player.id, right_id: friend.id)
    DB[:social_associations].insert(provider: provider_id, id: "fake-id-#{friend.id}", token: 'dont-care', player_id: friend.id)
  end
end

Given /^existing badges for "([^"]*)":$/ do |nickname, badges|
  player = Domain::Player.first!(nickname: nickname)
  rows = badges.raw.map do |identifier, count, level|
    {
      player_id: player.id,
      identifier: identifier,
      level: level.to_i,
      count: count.to_i,
      created_at: Time.now
    }
  end
  Domain::Badge.dataset.multi_insert(rows)
end
