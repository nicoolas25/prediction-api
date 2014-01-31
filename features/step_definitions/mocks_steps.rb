Given /^I have (a valid|an invalid) OAuth2 token for the "([^"]*)" provider(?: which returns the id "([^"]*)")?$/ do |valid, provider, id|
  klass = "SocialAPI::#{provider.camelize}".constantize
  messages = (valid == 'a valid') ?
    { social_id: id || SecureRandom.hex, first_name: 'John', last_name: 'Do' } :
    { social_id: nil }
  allow_any_instance_of(klass).to receive_messages(messages)
end

Given /^an user named "([^"]*)" is already registered$/ do |nickname|
  Domain::Player.create(nickname: nickname)
end

Given /^a social account for "([^"]*)"  with "([^"]*)" id is linked to "([^"]*)"$/ do |provider, id, nickname|
  player = Domain::Player.first!(nickname: nickname)
  player.add_social_association(provider: SocialAPI::PROVIDERS.index(provider), id: id, token: 'dont-care')
end
