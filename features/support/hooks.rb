require 'chronic'
require 'timecop'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, {pre_count: true}

Before do
  Domain::Services::Ranking.clean
  DatabaseCleaner.clean
end

Before do
  Chronic.time_class = Time
end

After do
  Timecop.return
end
