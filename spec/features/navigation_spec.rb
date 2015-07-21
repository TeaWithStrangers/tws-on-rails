require 'spec_helper'

feature 'Header navigation links' do
  scenario 'Non signed in user' do
    visit root_path
    expect(page.find('header nav')).to have_link('Hosting')
  end
end

feature 'Profile navigation links' do
  scenario 'host' do
    host = create(:user, :host)
    sign_in(host)
    visit profile_path
    expect(page.find('#profile-nav')).to have_link('Customize Reminder Email')
  end
  scenario 'As non host' do
    user = create(:user)
    sign_in(user)
    visit profile_path
    expect(page.find('#profile-nav')).not_to have_link('Customize Reminder Email')
  end
end
