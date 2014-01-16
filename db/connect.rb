require 'yaml'
require 'sequel'

database_file = File.join(ROOT_PATH, 'config', 'database.yml')
database = YAML.load_file(database_file)['config']
host = database['host']
port = database['post']
name = database['name']
user = database['user']

DB = Sequel.connect("postgres://#{host}:#{port}/#{name}?user=#{user}")
