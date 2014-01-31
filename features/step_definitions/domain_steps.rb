Then /^the "([^"]*)" user should have a valid token(?: equal to "([^"]*)")$/ do |nickname, json_path|
  player = Domain::Player.first!(nickname: nickname)
  expect(player.token_expiration).to be > Time.now

  if json_path.present?
    json    = JSON.parse(last_response.body)
    results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
    expect(results).to include(player.token)
  end
end
