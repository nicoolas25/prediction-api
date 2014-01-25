require 'pry'

# Run a coverage analysis during tests
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.use_merging false
  SimpleCov.start do
    # Do not run on spec files
    add_filter 'spec'

    # Create test groups
    add_group "Domain", 'app/domain'
  end

  # Load any domain file for coverage
  Dir.glob("./app/**/*.rb").each { |f| require f }
else
  require './app/domain'
end
