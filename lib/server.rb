require 'sinatra'
require 'json'

module GameOfShutl
  class Server < Sinatra::Base
    post '/quotes' do
      params = JSON.parse(params ? params : request.body.read)
      quote = params['quote']
      price = ((quote['pickup_postcode'].to_i(36) - quote['delivery_postcode'].to_i(36)) / 1000).abs

      {
        quote: {
          pickup_postcode: quote['pickup_postcode'],
          delivery_postcode: quote['delivery_postcode'],
          price: price
        }
      }.to_json
    end
  end
end