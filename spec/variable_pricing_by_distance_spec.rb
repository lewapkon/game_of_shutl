require 'spec_helper'

describe 'Variable pricing by distance' do
  it 'converts the postcodes to base-32, subtracts delivery from pickup and adds appropriate markup' do
    request = {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'parcel_car'
      }
    }.to_json

    post '/quotes', request

    quote = JSON.parse(last_response.body)['quote']
    expect(quote['price']).to eql 814.8
    expect(quote['vehicle']).to eql 'parcel_car'

    request = {
      quote: {
        pickup_postcode:   'AL1 5WD',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'small_van'
      }
    }.to_json

    post '/quotes', request

    quote = JSON.parse(last_response.body)['quote']
    expect(quote['price']).to eql 852.8
    expect(quote['vehicle']).to eql 'small_van'
  end

  it 'responds with a swapped vehicle' do
    request = {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'motorbike'
      }
    }.to_json

    post '/quotes', request

    quote = JSON.parse(last_response.body)['quote']
    expect(quote['price']).to eql 814.8
    expect(quote['vehicle']).to eql 'parcel_car'
  end

  it 'responds without a specified vehicle' do
    request = {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        products: [{
          weight: 10,
          width: 50,
          height: 50,
          length: 50
        }]
      }
    }.to_json

    post '/quotes', request

    quote = JSON.parse(last_response.body)['quote']
    expect(quote['price']).to eql 814.8
    expect(quote['vehicle']).to eql 'parcel_car'
  end

  it 'responds with invalid vehicle' do
    request = {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'forklift'
      }
    }.to_json

    post '/quotes', request

    error = JSON.parse(last_response.body)['error']
    expect(error).to eql 'invalid vehicle: forklift'
  end
end