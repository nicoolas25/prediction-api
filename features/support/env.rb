ENV['RACK_ENV'] = 'test'

require 'pry'
require 'rack'
require 'rack/test'
require 'cucumber/rspec/doubles'

def app
  Prediction::API
end

World(Rack::Test::Methods)

# Run a coverage analysis during tests
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.use_merging false
  SimpleCov.start do
    # Do not run on spec files
    add_filter 'features'

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

