require 'jsonpath'

Given /^I set headers:$/ do |headers|
  headers.rows_hash.each {|k,v| header k, v }
end

Given /^I (send and )?accept JSON$/ do |send|
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json' if send.present?
end

When /^I send a (GET|POST|PUT|DELETE) request (?:for|to) "([^"]*)"(?: with the following:)?$/ do |*args|
  request_type = args.shift
  path = args.shift
  input = args.shift

  request_opts = {method: request_type.downcase.to_sym}

  unless input.nil?
    if input.class == Cucumber::Ast::Table
      request_opts[:params] = input.rows_hash
    else
      request_opts[:input] = input
    end
  end

  request path, request_opts
end

Then /^the response status should be "([^"]*)"$/ do |status|
  expect(last_response.status).to eql(status.to_i)
end

Then /^the JSON response should (not)?\s?have "([^"]*)"$/ do |negative, json_path|
  json    = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)

  if negative.present?
    expect(results).to be_empty
  else
    expect(results).to_not be_empty
  end
end

Then /^the JSON response should (not)?\s?have "([^"]*)" with the text "([^"]*)"$/ do |negative, json_path, text|
  json     = JSON.parse(last_response.body)
  results  = JsonPath.new(json_path).on(json).to_a.map(&:to_s)

  if negative.present?
    expect(results).to_not include(text)
  else
    expect(results).to include(text)
  end
end

Then /^the JSON response should have (\d+) "([^"]*)"$/ do |given_size, json_path|
  json  = JSON.parse(last_response.body)
  count = JsonPath.new(json_path).on(json).to_a.size
  expect(count).to eql(given_size.to_i)
end

Then /^the JSON response should be:$/ do |json|
  expected = JSON.parse(json)
  actual = JSON.parse(last_response.body)
  expect(actual).to eql(expected)
end

Then /^show me the (unparsed)?\s?response$/ do |unparsed|
  if unparsed == 'unparsed'
    puts last_response.body
  elsif last_response.headers['Content-Type'] =~ /json/
    json_response = JSON.parse(last_response.body)
    puts JSON.pretty_generate(json_response)
  else
    puts last_response.headers
    puts last_response.body
  end
end
