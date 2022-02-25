require 'open-uri'
require 'net/http'
require 'json'

url = "https://en.wikipedia.org/wiki/Douglas_Adams"
url = URI.parse(url)
response = Net::HTTP.get_response(url)
JSON.parse(response.body)