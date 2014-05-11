Then /^the "([^"]*)" user should have a valid token(?: equal to "([^"]*)")$/ do |nickname, json_path|
  player = Domain::Player.first!(nickname: nickname)
  expect(player.token_expiration).to be > Time.now

  if json_path.present?
    json    = JSON.parse(last_response.body)
    results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
    expect(results).to include(player.token)
  end
end

Then /^the only registered players are:$/ do |users|
  user_nicknames = users.raw.flatten
  expected_size = user_nicknames.size

  size_1 = Domain::Player.dataset.where(nickname: user_nicknames).count
  expect(size_1).to eql(expected_size)

  size_2 = Domain::Player.dataset.exclude(nickname: user_nicknames).count
  expect(size_2).to eql(0)
end

Then /^a participation for the user "([^"]*)" to the question "([^"]*)" should exists$/ do |nickname, question_id|
  player = Domain::Player.first!(nickname: nickname)
  participations = player.questions_dataset.where(id: question_id).count
  expect(participations).to eql(1)
end

Then /^a question with label_(fr|en) set to "([^"]*)" should exist$/ do |locale, label|
  expect(Domain::Question.where(:"label_#{locale}" => label).count).to eql(1)
end

Then /^the question "([^"]*)" should have been answered$/ do |question_id|
  question = Domain::Question.where(id: question_id).first
  expect(question.answered).to eql(true)
end

Then /^the winnings for the question "(\d+)" are the following:$/ do |question_id, winnings|
  winnings.raw.each do |nickname, expected_winnings|
    player = Domain::Player.first!(nickname: nickname)
    participation = player.participations_dataset.where(question_id: question_id).first
    expect(participation.winnings).to eql(expected_winnings.to_i)
  end
end

Then /^the player "([^"]*)" should have "(\d+)" cristals$/ do |nickname, cristals|
  player = Domain::Player.first!(nickname: nickname)
  expect(player.cristals).to eql(cristals.to_i)
end

When /^the solution to the question "(\d+)" is:$/ do |question_id, components|
  question = Domain::Question.where(id: question_id).first!
  components = JSON.parse(components)
  question.answer_with(components)
end

Then /^the player "([^"]*)" should have "(\d+)" friends$/ do |nickname, count|
  player = Domain::Player.first!(nickname: nickname)
  expect(player.friends_dataset.count).to eql(count.to_i)
end

Then /^a "([^"]*)" badge for the user "([^"]*)" should( not)? exist$/ do |identifier, nickname, should_not|
  player = Domain::Player.first!(nickname: nickname)
  badges = player.badges_dataset.visible.where(identifier: identifier)
  if should_not == ' not'
    expect(badges.count).to eql(0)
  else
    expect(badges.count).to be >= 1
  end
end

Then /^the last share should be in "([^"]*)" with an id containing "([^"]*)"$/ do |locale, id|
  share = $shared_list.last
  expect(share).to_not be_nil
  expect(share[0].to_s).to eql(locale)
  expect(share[2].to_s).to match(id)
end

Then /^the "([^"]*)" attr of "([^"]*)" should be defined$/ do |attribute, nickname|
  player = Domain::Player.first!(nickname: nickname)
  value  = player.__send__(attribute)
  expect(value).to_not be_nil
end

Then /^the "([^"]*)" attr for badge "([^"]*)" with level "(\d+)" of "([^"]*)" should be defined$/ do |attribute, identifier, level, nickname|
  player = Domain::Player.first!(nickname: nickname)
  badge  = player.badges_dataset.where(identifier: identifier, level: level.to_i).first
  value  = badge.__send__(attribute)
  expect(value).to_not be_nil
end

Then /^the "([^"]*)" attr for participation to the question "(\d+)" of "([^"]*)" should be defined$/ do |attribute, question_id, nickname|
  player        = Domain::Player.first!(nickname: nickname)
  participation = player.participations_dataset.first!(question_id: question_id)
  value         = participation.__send__(attribute)
  expect(value).to_not be_nil
end

Then /^the player "([^"]*)" should have "(\d+)" available bonus$/ do |nickname, count|
  player = Domain::Player.first!(nickname: nickname)
  expect(Domain::Bonus.dataset.available_for(player).count).to eql(count.to_i)
end

Then /^the player "([^"]*)" should have "(\d+)" bonus$/ do |nickname, count|
  player = Domain::Player.first!(nickname: nickname)
  expect(player.bonuses_dataset.count).to eql(count.to_i)
end

Then /^the token for the "([^"]*)" social association of "([^"]*)" is "([^"]*)"$/ do |provider, nickname, token|
  player = Domain::Player.first!(nickname: nickname)
  assoc  = player.social_associations_dataset.where(provider: SocialAPI::PROVIDERS.index(provider)).first
  expect(assoc.token).to eql(token)
end

Then /^the social association for "([^"]*)" for "([^"]*)" should include those informations:$/ do |provider, nickname, infos|
  player = Domain::Player.first!(nickname: nickname)
  assoc = player.social_associations_dataset.where(provider: SocialAPI::PROVIDERS.index(provider)).first
  extra_infos = assoc.extra_information.content
  infos.raw.each do |key, value|
    expect(extra_infos[key]).to eql(value)
  end
end
