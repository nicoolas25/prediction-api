require 'yaml'
require 'sequel'

env = ENV['RACK_ENV'] || 'app'

database = YAML.load_file('./config/database.yml')[env]
puts "Using #{env} environment"
host = database['host']
port = database['port']
name = database['name']
user = database['user']
pass = database['pass']

url = "postgres://#{host}:#{port}/#{name}?user=#{user}"
url += "&password=#{pass}" if pass

DB = Sequel.connect(url)

# Extensions to this Database object
DB.extension :pg_hstore

if defined?(LOGGER)
  DB.loggers << LOGGER
  DB.log_warn_duration = 0.2
end
