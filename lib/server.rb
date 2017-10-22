require 'sinatra'
require 'json'

module GameOfShutl
  class Server < Sinatra::Base
    configure do
      set :vehicles_markup, {
        bicycle:    0.1,
        motorbike:  0.15,
        parcel_car: 0.2,
        small_van:  0.3,
        large_van:  0.4
      }
    end

    post '/quotes' do
      params = JSON.parse(params ? params : request.body.read)
      quote = params['quote']
      price = ((quote['pickup_postcode'].to_i(36) - quote['delivery_postcode'].to_i(36)) / 1000).abs
      vehicleMarkup = price * settings.vehicles_markup[quote['vehicle'].to_sym]

      {
        quote: {
          pickup_postcode: quote['pickup_postcode'],
          delivery_postcode: quote['delivery_postcode'],
          vehicle: quote['vehicle'],
          price: price + vehicleMarkup
        }
      }.to_json
    end
  end
end