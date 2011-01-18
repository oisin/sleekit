require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'json'
require 'net/http'

before do
  halt 405, {'Allow' => 'POST'}, "Awa' wi' ye!\n" unless request.request_method == 'POST' 
end

post '/scottish*' do 
  incoming = JSON.parse(request.body.string)
  if (incoming.nil? or !incoming.has_key?('text')) then
    status 400
  else
    # Load translation from other page
    http = Net::HTTP.new("www.whoohoo.co.uk", 80)
    data = "pageid=scottie&topic=translator&string=" + incoming['text']
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    resp, content = http.post('/main.asp', URI.escape(data), headers)
    
    # Scrape the result from piles of dreck
    doc = Hpricot(content)
    translation = (doc/"/html/body/table[3]/tr/td[3]/table/tr/td[2]/table/tr/td/form/b").inner_html
    status 200
    body(translation)
  end
end
