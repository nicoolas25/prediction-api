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
