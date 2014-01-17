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

group :development do
  gem 'mina', github: 'nadarei/mina', branch: 'master'
end

group :test do
  gem 'rspec', '~> 3.0.0.beta1'
end
