require 'nokogiri'

def fetch_file
	system "wget", "http://c3420952.r52.cf0.rackcdn.com/playerdata.xml"
end

def imageFor firstname, lastname
	doc = Nokogiri::XML(File.open("playerdata.xml"))
	res = doc.xpath("//P").select { |node| node["f"]==firstname.downcase.capitalize and node["s"] == lastname.upcase}
	puts "http://cdn.soccerwiki.org/images/player/" + res[0]["i"]
end


imageFor "karim", "benzema"
