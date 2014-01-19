require 'yaml'
require 'sequel'

database = YAML.load_file('./config/database.yml')['config']
host = database['host']
port = database['port']
name = database['name']
user = database['user']
url = "postgres://#{host}:#{port}/#{name}?user=#{user}"

DB = Sequel.connect(url)
