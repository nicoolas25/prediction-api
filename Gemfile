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

# Web interface
gem 'sinatra'

# Templating languages for the web ui
gem 'slim'
gem 'coffee-script'

# HTTP
gem 'httparty'

group :development do
  gem 'mina', github: 'nadarei/mina', branch: 'master'
end

group :test do
  gem 'rspec', '~> 3.0.0.beta1'
  gem 'simplecov'
  gem 'pry'
end
