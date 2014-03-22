source 'https://rubygems.org'

# Force the ruby on production
ruby '2.1.0' if ENV['RACK_ENV'] == 'production'

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

group :development do
  gem 'mina', github: 'nadarei/mina', branch: 'master'
end

group :test do
  gem 'pry'
  gem 'rack-test'
  gem 'jsonpath'
  gem 'rspec', '~> 3.0.0.beta1'
  gem 'cucumber'
  gem 'simplecov'
  gem 'database_cleaner'
end
