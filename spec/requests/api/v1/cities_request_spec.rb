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
      it 'should assign the created_by_user_id to the current user'

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
      @cities = FactoryGirl.create_list(:city, 5)
    end

    let(:first_record) do
      JSON.parse(response.body)['cities'].first
    end

    let(:returned_ids) do
      JSON.parse(response.body)['cities'].map { |c| c['id'] }
    end

    it 'returns all the cities' do
      get '/api/v1/cities'
      @cities.each do |city|
        expect(returned_ids).to include(city.id)
      end
    end

    expected_attributes = [:brew_status, :city_code, :description, :id, :name, :tagline, :timezone]
    expected_attributes.each do |attribute|
      it "serializes the #{attribute} attribute" do
        get '/api/v1/cities'
        expect(first_record.keys).to include(attribute.to_s)
      end
    end

    it 'only serializes the specified attributes' do
      get '/api/v1/cities'
      expect(first_record.keys.sort).to eq expected_attributes.sort.map(&:to_s)
    end
  end
end