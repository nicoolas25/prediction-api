require 'logger'
require 'active_support/core_ext/numeric'

# Keep 5 x 100 MB of logs
LOGGER ||= Logger.new('./log/app.log', 5, 100.megabytes)


