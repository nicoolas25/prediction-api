require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, {pre_count: true}


Before do
  Domain::Services::Ranking.clean
  DatabaseCleaner.clean
end
