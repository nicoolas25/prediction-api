require 'json'
require 'yaml'

TEAMS = YAML.load_file('./resources/teams.yml')
PLAYERS_IMAGES = YAML.load_file('./resources/players_images.yml')

result = TEAMS.map do |team|
  team.merge(players: PLAYERS_IMAGES[team['code']])
end

puts "root = exports ? this"
puts "root.countries = #{result.to_json}"
