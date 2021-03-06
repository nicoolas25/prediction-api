source 'https://rubygems.org'

# Force the ruby on production
ruby '2.1.1' if ENV['RACK_ENV'] == 'production'

# Web server
gem 'puma'

# Database
gem 'sequel'
gem 'pg'

# Framework
gem 'grape'
gem 'grape-entity'

# Add-ons
gem 'rack-cors'

# Web interface
gem 'sinatra'
gem 'sinatra-contrib'
gem 'tilt'

# Templating languages for the web ui
gem 'slim'
gem 'coffee-script'

# HTTP
gem 'httparty'

# Social API clients
gem 'twitter'
gem 'google-api-client'

# Backup related gems
gem 'dropbox-sdk'

# Asynchronous jobs
gem 'sidekiq'

# Cron jobs
gem 'whenever'

group :development do
  gem 'mina', github: 'nadarei/mina', branch: 'master'
  gem 'rerun'
end

group :test do
  gem 'pry'
  gem 'rack-test'
  gem 'jsonpath'
  gem 'rspec', '3.0.0.beta1'
  gem 'cucumber'
  gem 'simplecov'
  gem 'database_cleaner'
  gem 'chronic'
  gem 'timecop'
end
