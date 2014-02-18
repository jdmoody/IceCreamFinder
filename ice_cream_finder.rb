require 'rest-client'
require 'json'
require 'nokogiri'
require 'addressable/uri'

puts "To find THE best ice cream nearby, please enter your address: "
address = gets.chomp
#"1061 Market St, San Francisco, CA 94103"

current_location_URL = Addressable::URI.new(
:scheme =>  "https",
:host => "maps.googleapis.com",
:path => "maps/api/geocode/json",
:query_values => {
  :address => address,
  :sensor => "false"
},
:key => "AIzaSyAmQbUlgqpQZnUcv_pSO7QwmbFTL5H15Nw"
).to_s

current_location = JSON.parse(RestClient.get(current_location_URL))


lat_lng = "#{current_location["results"][0]["geometry"]["location"]["lat"]}," +
          "#{current_location["results"][0]["geometry"]["location"]["lng"]}"

ice_cream_shops = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/place/textsearch/json",
:query_values => {
  :key => "AIzaSyAmQbUlgqpQZnUcv_pSO7QwmbFTL5H15Nw",
  :location => lat_lng,
  :radius => 1000,
  :sensor => false,
  :query => "Ice Cream"
  }
).to_s

ice_cream_parsed = JSON.parse(RestClient.get(ice_cream_shops))

best_place = nil

ice_cream_parsed["results"].each do |shop|
  next if shop["rating"].nil?
  if best_place.nil? || best_place["rating"] < shop["rating"]
    best_place = shop
    next
  end

end

puts best_place["name"]
puts "Address #{best_place["formatted_address"]}"
puts "Rating: #{best_place["rating"]}"
puts "*" * 50
puts "Directions:"
puts
directions_URL = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/directions/json",
:query_values => {
  :key => "AIzaSyAmQbUlgqpQZnUcv_pSO7QwmbFTL5H15Nw",
  :origin => lat_lng,
  :destination => best_place["formatted_address"],
  :sensor => false,
  :mode => "walking"
  }
).to_s

directions_list = JSON.parse(RestClient.get(directions_URL))


directions_list["routes"][0]["legs"][0]["steps"].each do |step|
  puts Nokogiri::HTML(step["html_instructions"]).text + "     => #{step["distance"]["text"]}"
end