#!/usr/bin/env ruby

require 'pry'
require 'nokogiri'
require 'open-uri'

LINKS = [
  "http://fr.wikipedia.org/wiki/%C3%89quipe_des_%C3%89tats-Unis_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Costa_Rica_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Honduras_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Mexique_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Belgique_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Italie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Allemagne_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_des_Pays-Bas_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Suisse_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Russie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Bosnie-Herz%C3%A9govine_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Angleterre_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Espagne_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Croatie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Gr%C3%A8ce_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Portugal_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_France_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Br%C3%A9sil_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Argentine_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Colombie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Chili_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27%C3%89quateur_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Uruguay_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Japon_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_Cor%C3%A9e_du_Sud_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Iran_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Australie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_d%27Alg%C3%A9rie_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Cameroun_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_de_C%C3%B4te_d%27Ivoire_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Ghana_de_football_%C3%A0_la_Coupe_du_monde_2014",
  "http://fr.wikipedia.org/wiki/%C3%89quipe_du_Nigeria_de_football_%C3%A0_la_Coupe_du_monde_2014",
]

class TeamExtractor
  def initialize(url)
    @page = Nokogiri::HTML(open(url))
  end

  def team_name
    @team_name ||= begin
      td = @page.css('h1.firstHeading')
      td.text =~ /Équipe (?:de |des |du |d')(.+) de football/
      $1
    end
  end

  def players
    @players ||= begin
      result = []
      player_table.css('tr td:first-child').each do |player_td|
        max = 0
        name = player_td.text.strip
        while (player_td = player_td.next_element) && (name == '' || name =~ /^-| $/) && (max += 1) < 5
          name = player_td.text.strip
        end
        result << name unless max == 5
      end
      result
    end
  end

  private

  def player_table
    @player_table ||= begin
      @page.css('table').each do |table|
        next if table.attributes['class']
        next if table.ancestors('.infobox_v2').any?
        next if table.ancestors('.bandeau').any?
        break table
      end
    end
  end
end

LINKS.each do |url|
  t = TeamExtractor.new(url)
  begin
    t.players.each do |player|
      puts "%s : %s" % [t.team_name, player]
    end
    puts ''
  rescue
    # Allow debugging when it fails
    binding.pry
    break
  end
end
