require 'i18n'
require 'nokogiri'
require 'htmlentities'
require 'yaml'

PLAYERS  = YAML.load_file('./resources/players.yml')
FILENAME = "playerdata.xml"
FILEPATH = File.join(File.dirname(__FILE__), FILENAME)

DECODER = HTMLEntities.new

def fetch_file
  system "wget", "http://c3420952.r52.cf0.rackcdn.com/#{FILENAME}"
  system "mv", FILENAME, FILEPATH
end

def players_hash
  @players_hash ||= begin
    doc = Nokogiri::XML(File.open(FILEPATH))
    hash = {}
    doc.xpath("//P").select do |node|
      key = "#{node['f']} #{node['s']}"
      key = DECODER.decode(key)
      key = I18n.transliterate(key)
      key = key.downcase
      hash[key] ||= []
      hash[key]  << node['i'] if node['i']
    end
    hash
  end
end

def imageFor(name)
  name = I18n.transliterate(name.downcase)
  if files = players_hash[name]
    "http://cdn.soccerwiki.org/images/player/#{files[0]}"
  else
    'missing'
  end
end

PLAYERS.each do |country, players|
  players.each do |player|
    if player['url'] == 'missing'
      player['url'] = imageFor(player['name'])
    end
  end
end

puts PLAYERS.to_yaml
