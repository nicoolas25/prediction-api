require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, {pre_count: true}


Before do
  DatabaseCleaner.clean
end
