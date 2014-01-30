ENV['RACK_ENV'] = 'test'

require 'pry'
require 'rack/test'

# Run a coverage analysis during tests
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.use_merging false
  SimpleCov.start do
    # Do not run on spec files
    add_filter 'spec'

    # Create test groups
    add_group "Domain",     'app/domain'
    add_group "Controller", 'app/controllers'
    add_group "Entity",     'app/entities'
  end

  require './app/controllers'
  require './app/domain'
  require './app/entities'

  # Load any autoloaded file for coverage
  Dir.glob("./app/**/*.rb").each { |f| require f }
else
  require './app/controllers'
end

module SpecHelpers
  def mock_social_id(provider, test_id=nil)
    klass = "SocialAPI::#{provider.camelize}".constantize
    allow_any_instance_of(klass).to receive_messages({
      social_id: test_id || SecureRandom.hex,
      first_name: 'John',
      last_name: 'Do'
    })
  end

  def mock_social_id_miss(provider)
    klass = "SocialAPI::#{provider.camelize}".constantize
    allow_any_instance_of(klass).to receive_messages(social_id: nil)
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SpecHelpers
end
