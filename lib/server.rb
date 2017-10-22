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
      # kg
      set :vehicle_weight_limits, {
        bicycle:    3,
        motorbike:  6,
        parcel_car: 50,
        small_van:  400
      }
      # LxWxH, cm
      set :vehicle_capacity_limits, {
        bicycle:    [ 30,  25,  10],
        motorbike:  [ 35,  25,  25],
        parcel_car: [100, 100,  75],
        small_van:  [133, 133, 133]
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

      vehicle = quote['vehicle'] != nil ? quote['vehicle'].to_sym : find_smallest_vehicle(quote['products'])

      vehicle, vehicle_markup = find_sufficient_vehicle(vehicle, base_price)
      if vehicle == :invalid_vehicle then
        return {
          error: "invalid vehicle: #{quote['vehicle']}"
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

    def find_smallest_vehicle(products)
      product = products[0]
      big_enough_vehicle = settings.vehicles.find { |vehicle|
        weight_limit = settings.vehicle_weight_limits[vehicle]
        capacity_limit = settings.vehicle_capacity_limits[vehicle]
        good_weight?(product, weight_limit) and fits?(product, capacity_limit)
      }
      big_enough_vehicle || :large_van
    end

    def good_weight?(product, weight_limit)
      weight_limit == nil or product['weight'] <= weight_limit
    end

    def fits?(product, capacity)
      capacity == nil or
        (product['length'] <= capacity[0] and
         product['width']  <= capacity[1] and
         product['height'] <= capacity[2])
    end

    def find_sufficient_vehicle(vehicle, base_price)
      vehicle_markup = 0
      vehicle_idx = settings.vehicles.index(vehicle)

      if vehicle_idx == nil then
        return [:invalid_vehicle, 0]
      end

      loop do
        vehicle_markup = base_price * settings.vehicle_markups[vehicle]
        limit = settings.vehicle_price_limits[vehicle]
        break if limit == nil or base_price + vehicle_markup <= limit

        vehicle_idx += 1
        vehicle = settings.vehicles[vehicle_idx]
      end
      [vehicle, vehicle_markup]
    end
  end
end