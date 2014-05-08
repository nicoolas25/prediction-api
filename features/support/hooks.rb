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

  # Assume that some constant are different to avoir random behaviours
  stub_const('Domain::Participation::BONUS_CHANCES', 0.0)
end

After do
  Timecop.return
end
