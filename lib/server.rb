require 'sinatra'
require 'json'

module GameOfShutl
  class Server < Sinatra::Base
    configure do
      set :vehicles, [:bicycle, :motorbike, :parcel_car, :small_van, :large_van]
      set :vehicle_markups, {
        bicycle:    0.1,
        motorbike:  0.15,
        parcel_car: 0.2,
        small_van:  0.3,
        large_van:  0.4
      }
      set :vehicle_price_limits, {
        bicycle:    500,
        motorbike:  750,
        parcel_car: 1000,
        small_van:  1500
      }
    end

    post '/quotes' do
      params = JSON.parse(params ? params : request.body.read)
      quote = params['quote']
      base_price = ((quote['pickup_postcode'].to_i(36) - quote['delivery_postcode'].to_i(36)) / 1000).abs

      vehicle, vehicle_markup = findSufficientVehicle(quote['vehicle'].to_sym, base_price)
      if vehicle == :invalid_vehicle then
        return {
          error: "invalid vehicle"
        }.to_json
      end

      {
        quote: {
          pickup_postcode: quote['pickup_postcode'],
          delivery_postcode: quote['delivery_postcode'],
          vehicle: vehicle,
          price: base_price + vehicle_markup
        }
      }.to_json
    end

    def findSufficientVehicle(vehicle, base_price)
      vehicle_markup = 0
      vehicle_idx = settings.vehicles.index(vehicle)

      if vehicle_idx == nil then
        return [:invalid_vehicle, 0]
      end

      loop do
        vehicle_markup = base_price * settings.vehicle_markups[vehicle]
        limit = settings.vehicle_price_limits[vehicle]
        break if limit == nil || base_price + vehicle_markup <= limit

        vehicle_idx += 1
        vehicle = settings.vehicles[vehicle_idx]
      end
      return [vehicle, vehicle_markup]
    end
  end
end