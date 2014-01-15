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

group :deployment do
  gem 'mina', github: 'nadarei/mina', branch: 'master'
end
