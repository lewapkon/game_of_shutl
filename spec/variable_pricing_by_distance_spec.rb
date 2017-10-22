require 'spec_helper'

describe 'Variable pricing by distance' do
  it 'converts the postcodes to base-32 and subtracts delivery from pickup' do
    request = {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'parcel_car'
      }
    }.to_json

    post '/quotes', request
    expect(JSON.parse(last_response.body)['quote']['price']).to eql 814.8

    request = {
      quote: {
        pickup_postcode:   'AL1 5WD',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'small_van'
      }
    }.to_json

    post '/quotes', request

    quote = JSON.parse(last_response.body)['quote']
    expect(JSON.parse(last_response.body)['quote']['price']).to eql 852.8
  end
end