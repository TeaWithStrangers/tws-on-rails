require 'spec_helper'

describe CitiesController do
  before do
    [:away_ye_waitlisted, :authenticate_user!, :authorized?].each do |s|
      allow(controller).to receive(s).and_return true
    end
  end

  describe '#update' do
    let(:unapproved_city) { 
      city = create(:city, :unapproved) 
      (1..10).each { |i| create(:user, home_city: city) }
      city
    }

    let(:merge_request) {
      {
        id: unapproved_city.city_code,
        city: {id: unapproved_city.id},
        merge_city_id: create(:city).id,
        approval_action: "merge"
      }
    }

    it 'should move all users from City A to City B upon merge' do
      city_a = unapproved_city
      city_a_users = city_a.users
      city_b_id = merge_request[:merge_city_id]

      patch :update, merge_request
      expect(response).to redirect_to(city_path(city_a))
      expect(city_a_users.map { 
        |u| u.reload.home_city_id == city_b_id 
      }.all?).to eq(true)
    end
  end
end
