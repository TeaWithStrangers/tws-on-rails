require 'spec_helper'

describe 'Cities endpoint', type: :request do
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