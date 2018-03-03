require 'spec_helper'

describe 'Cities endpoint', type: :request do
  describe 'create endpoint' do
    let(:payload) do
      {
        city: {
          name: "Wonderland"
        }
      }
    end

    let(:created_city) do
      City.find_by(name: payload[:city][:name])
    end

    context 'Logged in users' do

      before(:each) do

        # TODO figure out how to do this the right way
        # with Devise helpers
        allow_any_instance_of(Api::V1::CitiesController).to receive(:user_signed_in?).and_return(true)
      end

      it 'should create a city' do
        post '/api/v1/cities', payload
        expect(created_city).not_to be nil
      end

      it 'should set status to unapproved' do
        post '/api/v1/cities', payload
        expect(created_city.brew_status).to eq "unapproved"
      end
      it 'should return a 200' do
        post '/api/v1/cities', payload
        expect(response.status).to eq 200
      end
      it 'should return created city in JSON response' do
        post '/api/v1/cities', payload
        expect(JSON.parse(response.body)['city']['name']).to eq payload[:city][:name]
      end
    end
    context 'Unauthenticated users' do
      it 'should not create a city' do
        post '/api/v1/cities', payload
        expect(created_city).to be nil
      end
      it 'should return a 401' do
        post '/api/v1/cities', payload
        expect(response.status).to eq 401
      end
      it 'should return unauthenticated in the response body' do
        post '/api/v1/cities', payload
        expect(response.body).to match(/unauthenticated/)
      end
    end
  end

  describe 'index endpoint' do
    before(:each) do
      @cities = FactoryBot.create_list(:city, 5)
    end

    let(:json_response) do
      JSON.parse(response.body)
    end

    let(:first_record) do
      json_response['cities'].first
    end

    let(:returned_ids) do
      json_response['cities'].map { |c| c['id'] }
    end

    it 'returns all the cities' do
      get '/api/v1/cities'
      @cities.each do |city|
        expect(returned_ids).to include(city.id)
      end
    end

    it 'should return a URL to small version of the header bg' do
      new_city = create(:city, header_bg: File.open("#{Rails.root}/spec/fixtures/missing-city-image.jpg"))
      get '/api/v1/cities'
      returned_target = json_response['cities'].find { |x| x['id'] == new_city.id }
      expect(returned_target['header_bg_small']).to eq new_city.header_bg(:small)
    end

    it 'should return the users_count' do
      target_test_city = @cities.first
      new_users = FactoryBot.create_list(:user, 2, home_city_id: target_test_city.id)
      get '/api/v1/cities'
      returned_target = json_response['cities'].find { |x| x['id'] == target_test_city.id }
      expect(returned_target['info']['user_count']).to eq new_users.length
    end

    it 'should returns ciites sorted by user count' do
      # create a different number of users for each city
      @cities.shuffle.each_with_index do |city, index|
        num = index + 1
        num.times { create_list(:user, num, home_city_id: city.id) }
      end
      get '/api/v1/cities'
      expect(returned_ids).to eq City.order(users_count: :desc).map(&:id)
    end

    #expected_attributes = [:brew_status, :city_code, :description, :id, :name, :tagline, :timezone]
    #expected_attributes.each do |attribute|
    #  it "serializes the #{attribute} attribute" do
    #    get '/api/v1/cities'
    #    expect(first_record.keys).to include(attribute.to_s)
    #  end
    #end

    #it 'only serializes the specified attributes' do
    #  get '/api/v1/cities'
    #  expect(first_record.keys.sort).to eq expected_attributes.sort.map(&:to_s)
    #end
  end
end
