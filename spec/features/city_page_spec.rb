require 'spec_helper'

feature 'City page' do
  scenario 'Unauthenticated user' do
    city = create(:city, name: "Bahamas", city_code: "XY")
    visit city_path(city)
    expect(page).to have_text("Bahamas")
    expect(page).not_to have_css('flash alert')
    expect(page.current_path).to eq city_path(city)
  end
end
