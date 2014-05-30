require 'yaml'
require 'sequel'

SEQUEL_MIGRATION_DIR = File.join(File.dirname(__FILE__), 'migrations')

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

# In test mode try the connection differs
if ENV['RACK_ENV'] == 'test'
  # Create
  %x{createdb -U #{user} -p #{port} #{name}}

  DB = Sequel.connect(url)

  # Load DB extensions
  %w(hstore).each do |ext|
    DB.run "create extension if not exists #{ext};"
  end

  # Migrate
  Sequel.extension :migration
  Sequel::Migrator.run(DB, SEQUEL_MIGRATION_DIR)
else
  DB = Sequel.connect(url)
end

# Extensions to this Database object
DB.extension :pg_hstore

if defined?(LOGGER)
  DB.loggers << LOGGER
  DB.log_warn_duration = 0.2
end
