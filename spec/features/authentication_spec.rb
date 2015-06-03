require 'spec_helper'

feature 'Authentication' do
  scenario 'logging in' do
    @city = create(:city)
    @u = create(:user, :host, home_city: @city)
    sign_in @u
    expect(page.body).to match(/sign out/i)
  end

  scenario 'logging out' do
    @city = create(:city)
    @u = create(:user, :host, home_city: @city)
    sign_in @u
    sign_out
    expect(page.body).to match(/sign in/i)
  end
end
