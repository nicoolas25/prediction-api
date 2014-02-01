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
