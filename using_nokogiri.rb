require "HTTParty"
# require 'open-uri'
require 'json'
require 'nokogiri'
require 'csv'

result = []
html = HTTParty.get("https://en.wikipedia.org/wiki/Douglas_Adams")
# using open-uri
# html = open("https://en.wikipedia.org/wiki/Douglas_Adams")
doc = Nokogiri::HTML(html)
desc = doc.css("p").text.split("\n").find{ |d| d.length > 0 }
# desc = doc.css("p")[1].children[0]
p desc
picture = doc.css("td a img").find{|picture| picture.attributes["alt"].value.include?("Douglas adams portrait cropped.jpg")}.attributes["src"].value

result.push([desc,picture])

CSV.open('result.csv',"w") do |csv|
    csv << result
end