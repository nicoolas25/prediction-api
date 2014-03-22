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

# Fake application config
APPLICATION_CONFIG = {
  stakes: {
    min: 10,
    max: 1000
  },
  avatars: {
    small: {
      facebook: "http://graph.facebook.com/__id__/picture?height=100&width=100",
      googleplus: "https://plus.google.com/s2/photos/profile/__id__?sz=100",
      twitter: ""
    },
    big: {
      facebook: "http://graph.facebook.com/__id__/picture?height=300&width=300",
      googleplus: "https://plus.google.com/s2/photos/profile/__id__?sz=300",
      twitter: ""
    }
  }
}


