require 'logger'
require 'active_support/core_ext/numeric'

env = ENV['RACK_ENV'] || 'app'

# Keep 5 x 100 MB of logs
LOGGER ||= Logger.new("./log/#{env}.log", 5, 100.megabytes)


