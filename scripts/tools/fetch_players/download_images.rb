require 'yaml'

PLAYERS = YAML.load_file('./resources/players.yml')
MAPPING = {}

count = 0
PLAYERS.each do |country, players|
  MAPPING[country] ||= []
  players.each do |player|
    count += 1
    if url = player['url']
      url =~ /\.(jpg|gif|png|jpeg)$/i
      ext = $1
      target = "p/#{count}.#{ext}"
      system 'wget', url, '-O', "./resources/#{target}"
    else
      target = 'p/0.jpg'
    end

    MAPPING[country] << {name: player['name'], image: target}
  end
end

puts MAPPING.to_yaml
