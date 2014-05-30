DEFAULT_CRISTALS = 20

# Fake the provider response for friends
def fake_friends(provider, *results)
  klass = "SocialAPI::#{provider.camelize}".constantize
  count = 0
  allow_any_instance_of(klass).to receive(:friend_ids) do
    if results.any?
      result = results[count] || results.last
      count += 1
      result
    else
      []
    end
  end
end

def fake_informations(provider, infos={})
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = { extra_informations: infos }
  allow_any_instance_of(klass).to receive_messages(messages)
end

def fake_social_id(provider, social_id=nil)
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = { social_id: social_id, email: 'john@do.org', first_name: 'John', last_name: 'Do', avatar_url: 'http://example.org/image.png' }
  allow_any_instance_of(klass).to receive_messages(messages)
end

$shared_list = []
def fake_social_share(provider, success)
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = { social_id: 'fake-id' }
  allow_any_instance_of(klass).to receive_messages(messages)
  allow_any_instance_of(klass).to receive(:share) do |obj, *args|
    $shared_list << args
    success
  end
end

def fake_payment(provider, transaction_id, product_id)
  klass = "PaymentAPI::#{provider.camelize}".constantize
  messages = { transaction_id: transaction_id, product_id: product_id }
  allow_any_instance_of(klass).to receive_messages(messages)
end

Given /^the player informations given by "([^"]*)" are:$/ do |provider, infos|
  fake_informations(provider, Hash[infos.raw])
end

Given /^the lucky bonus give "(\d+)" percent of chance of getting a bonus$/ do |percent|
  chances = percent.to_i / 100.0
  stub_const('Domain::Bonuses::Lucky::BONUS_CHANCES', chances)
end

Given /^the players with nickname prefix "([^"]*)" have random scores$/ do |nickname_prefix|
  Domain::Services::Ranking.prepare
  player_ids = Domain::Player.where(Sequel.like(:nickname, "#{nickname_prefix}%")).select(:id)
  DB[:scorings].where(player_id: player_ids).update(score: Sequel.function(:random) * 1000)
  Domain::Services::Ranking.update_rankings
end

Given /^the player "([^"]*)" has a ranking of "(\d+)"$/ do |nickname, ranking|
  player = Domain::Player.first!(nickname: nickname)
  target_rank = ranking.to_i
  current_rank = Domain::Services::Ranking.rank(player)
  if target_rank != current_rank
    # Find and swap the desired user
    current_score = DB[:scorings].where(player_id: player.id).select(:score).first[:score]
    target_id = DB[:rankings].where(rank: target_rank).select(:player_id).first[:player_id]
    target_score = DB[:scorings].where(player_id: target_id).select(:score).first[:score]
    DB[:rankings].where(player_id: target_id).update(rank: current_rank)
    DB[:rankings].where(player_id: player.id).update(rank: target_rank)
    DB[:scorings].where(player_id: target_id).update(score: current_score)
    DB[:scorings].where(player_id: player.id).update(score: target_score)
  end
end

Given /^the percentage of change to get a bonus after a participation is "(\d+)"$/ do |percent|
  chances = percent.to_i / 100.0
  stub_const('Domain::Participation::BONUS_CHANCES', chances)
end

Given /^the "([^"]*)" payment api respond with trasanction "([^"]*)" and product "([^"]*)"$/ do |provider, tid, pid|
  tid = nil if tid == 'nil'
  fake_payment(provider, tid, pid)
end

Given /^(a valid|an invalid) OAuth2 token for the "([^"]*)" provider(?: which returns the id "([^"]*)")?$/ do |valid, provider, id|
  social_id = (valid == 'a valid') && (id || SecureRandom.hex)
  fake_social_id(provider, social_id)
  fake_friends(provider)
end

Given /^an user "([^"]*)" is already registered(?: with the id "(\d+)")?$/ do |nickname, id|
  player_params = {nickname: nickname, cristals: DEFAULT_CRISTALS}
  player_params[:id] = id.to_i if id.present?
  Domain::Player.create(player_params)
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

Given /^a social account for "([^"]*)" with "([^"]*)" id is linked to "([^"]*)"$/ do |provider, id, nickname|
  fake_friends(provider)
  player = Domain::Player.first!(nickname: nickname)
  provider_id = SocialAPI::PROVIDERS.index(provider)
  player.add_social_association(provider: provider_id, id: id, token: 'dont-care', avatar_url: 'http://example.org.image.png')
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
    attrs[:expires_at] = expired.present? ? (Time.now - 3.day) : (Time.now + 3.day)
    Domain::Question.create(attrs)
  end
end

Given /^existing tags:$/ do |tags|
  tags.raw.each do |question_id, keyword, tag_id|
    question = question_id.present? && Domain::Question.first(id: question_id)
    tag = Domain::Tag.first(keyword: keyword, id: tag_id) || Domain::Tag.create(keyword: keyword, id: tag_id)
    question.add_tag(tag) if question
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
  player.participate_to!(question, stakes, raw_answers, nil)
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

Given /^there is the following bonuses for the question "([^"]*)":$/ do |question_id, bonuses|
  question = Domain::Question.first!(id: question_id)
  bonuses.raw.each do |nickname, bonus_identifier|
    player = Domain::Player.first!(nickname: nickname)
    participation = Domain::Participation.where(player_id: player.id, question_id: question_id.to_i).first
    if participation
      Domain::Bonus.create({
        prediction_id: participation.prediction_id,
        player_id: player.id,
        identifier: bonus_identifier
      })
    end
  end
end

Given /^there are already registered players via "([^"]*)" friends to the id "([^"]*)":$/ do |provider, social_id, friends|
  provider_id = SocialAPI::PROVIDERS.index(provider)

  # Create the players and their social associations
  fake_friends(provider, [])
  friends.raw.map do |nickname, friend_social_id|
    player = Domain::Player.create(nickname: nickname, cristals: DEFAULT_CRISTALS)
    player.add_social_association(provider: provider_id, id: friend_social_id, token: 'not-revelent', avatar_url: 'http://example.org.image.png')
  end

  fake_friends(provider, friends.raw.map(&:last))
end

Given /^there is the following friend_ids results for "([^"]*)" over time:$/ do |provider, friends|
  lists = friends.raw.group_by(&:first).values.map { |e| e.map(&:last) }
  fake_friends(provider, *lists)
end

Given /^the user "([^"]*)" have the following "([^"]*)" friends:$/ do |nickname, provider, friends|
  provider_id = SocialAPI::PROVIDERS.index(provider)
  player = Domain::Player.first!(nickname: nickname)
  friends.raw.map do |nickname|
    friend = Domain::Player.first!(nickname: nickname)
    DB[:friendships].insert(provider: provider_id, left_id: player.id, right_id: friend.id)
    DB[:social_associations].insert(provider: provider_id, id: "fake-id-#{friend.id}", token: 'dont-care', player_id: friend.id, avatar_url: 'http://example.org.image.png')
  end
end

Given /^existing badges for "([^"]*)":$/ do |nickname, badges|
  player = Domain::Player.first!(nickname: nickname)
  badges.raw.each do |identifier, count, level|
    if last_badge = player.badges_dataset.for(identifier).order(Sequel.desc(:level)).first
      last_badge.update({
        level: level.to_i,
        count: count.to_i,
        created_at: Time.now
      })
    else
      Domain::Badge.dataset.insert({
        player_id: player.id,
        identifier: identifier,
        level: level.to_i,
        count: count.to_i,
        created_at: Time.now
      })
    end
  end
end

Given /^the "([^"]*)" provider (will|will not) share the messages correctly$/ do |provider, will|
  fake_social_share(provider, will == 'will')
end

Given /^the ranking service is already prepared$/ do
  Domain::Services::Ranking.prepare
end

Given /^the last auto-earned cristals for "([^"]*)" are "(\d+ [^"]*)" from now$/ do |nickname, time|
  player = Domain::Player.first!(nickname: nickname)
  count, unit = time.split(' ')
  time = Time.now - count.to_i.__send__(unit)
  player.update(auto_earn_at: time)
end

Given /^the "([^"]*)" badge level "(\d+)" of "([^"]*)" is already converted$/ do |identifier, level, nickname|
  player = Domain::Player.first!(nickname: nickname)
  badge  = player.badges_dataset.where(identifier: identifier, level: level.to_i).first
  badge.update(converted_to: 0)
end

Given /^the player "([^"]*)" have the following (used )?bonuses:$/ do |nickname, used, bonuses|
  player = Domain::Player.first!(nickname: nickname)
  bonuses.raw.each do |bonus_identifier|
    Domain::Bonus.create(
      player_id: player.id,
      identifier: bonus_identifier,
      prediction_id: used ? player.predictions_dataset.first.id : nil
    )
  end
end

Given /^the question "(\d+)" isn't visible until "([^"]*)"$/ do |question_id, time|
  time     = Chronic.parse(time) || Time.parse(time)
  question = Domain::Question.first!(id: question_id)
  question.update(reveals_at: time)
end
