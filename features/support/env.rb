ENV['RACK_ENV'] = 'test'

require 'pry'
require 'rack'
require 'rack/test'
require 'cucumber/rspec/doubles'

def app
  LoggerMiddleware.new Prediction::API
end

World(Rack::Test::Methods)

# Run a coverage analysis during tests
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.use_merging false
  SimpleCov.start do
    # Do not run on spec files
    add_filter 'features'
    add_filter 'lib/payment_api'
    add_filter 'lib/social_api'

    # Create test groups
    add_group "Domain",     'app/domain'
    add_group "Controller", 'app/controllers'
    add_group "Entity",     'app/entities'
  end

  require './api'

  # Load any autoloaded file for coverage
  Dir.glob("./app/**/*.rb").each { |f| require f }
else
  require './api'
end

require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Fake application config
APPLICATION_CONFIG = {
  stakes: {
    min: 10,
    max: 1000
  }
}
