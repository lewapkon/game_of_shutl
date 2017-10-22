require 'spec_helper'

describe 'Basic Service' do
  let(:request) do
    {
      quote: {
        pickup_postcode:   'SW1A 1AA',
        delivery_postcode: 'EC2A 3LT',
        vehicle:           'motorbike'
      }
    }.to_json
  end

  it 'responds to POST /quotes with a JSON response and a static price' do
    post '/quotes', request

    expect(last_response).to be_ok

    quote = JSON.parse(last_response.body)['quote']

    expect(quote['pickup_postcode']).to eql "SW1A 1AA"
    expect(quote['delivery_postcode']).to eql "EC2A 3LT"
    expect(quote['vehicle']).to eql "parcel_car"
    expect(quote['price']).to eql 814.8
  end
end