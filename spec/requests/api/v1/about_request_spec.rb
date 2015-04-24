require 'spec_helper'

describe 'API About endpoint' do
  it 'returns a name' do
    get '/api/v1/about'
    json_response = JSON.parse(response.body)
    expect(json_response['about']['name']).to eq "TWS::API"
  end

  it 'returns the version' do
    get '/api/v1/about'
    json_response = JSON.parse(response.body)
    expect(json_response['about']['current_sha']).to eq `cd #{Rails.root}; git rev-parse HEAD`
  end
end