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

Given /^the user "([^"]*)" have a valid token(?:: "([^"]*))?"$/ do |nickname, token|
  player = Domain::Player.first!(nickname: nickname)
  player.token = token.presence || SecureRandom.hex
  player.token_expiration = Time.now + 1.day
  player.save
end

Given /^a social account for "([^"]*)"  with "([^"]*)" id is linked to "([^"]*)"$/ do |provider, id, nickname|
  player = Domain::Player.first!(nickname: nickname)
  player.add_social_association(provider: SocialAPI::PROVIDERS.index(provider), id: id, token: 'dont-care')
end

Given /^I am an authenticated user$/ do
  nickname = "nickname"
  steps %Q{
    Given an user named "#{nickname}" is already registered
    And the user "#{nickname}" have a valid token: "12345"
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
  components.raw.each_with_index do |(kind, label, *extra), position|
    attrs = {}
    attrs[:kind] = Domain::QuestionComponent::KINDS.index(kind)
    attrs[:position] = position
    attrs[:label_fr] = label
    attrs[:choices_fr] = (kind == 'choices') ? extra.shift : nil
    attrs[:question_id] = question_id
    attrs[:valid_answer] = extra.shift.try(:to_f)
    Domain::QuestionComponent.create(attrs)
  end
end
