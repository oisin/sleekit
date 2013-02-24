require 'sinatra'
require 'hpricot'
require 'json'
require 'net/http'

before do
  halt 405, {'Allow' => 'POST'}, "Awa' wi' ye!\n" unless request.request_method == 'POST' 
end

post '/scottish*' do 
  incoming = JSON.parse(request.body.read)
  halt 400 if (incoming.nil? or !incoming.has_key?('text'))

  # Load translation from other page
  http = Net::HTTP.new("www.whoohoo.co.uk", 80)
  data = "pageid=scottie&topic=translator&string=" + incoming['text']

  request = Net::HTTP::Post.new('/main.asp?' + URI.escape(data))
  request['Convent-Type'] = 'application/x-www-form-urlencoded'
  # The target website requires the Content-Length header to be set or 411
  request['Content-Length'] = 0
  response = http.request(request)
  
  # Scrape the result from piles of dreck
  doc = Hpricot(response.body)    
  translation = (doc/"/html/body/table[3]/tr/td[3]/table/tr/td[2]/table/tr/td/form/b").inner_html
  halt 404 if (translation.nil? or translation.empty?)
  
  [200, {"Content-Type" => "text/plain"}, body(translation)]
end
