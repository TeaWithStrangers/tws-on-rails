require 'spec_helper'
feature 'First time visitor signs up' do
  before(:all) do
    @host = create(:user, :host)
    @tt = create(:tea_time, host: @host)
  end

  scenario 'with valid email and password' do
    sign_up_with('Darth Helmet', 'drthhlmt@spaceballone.com')
    expect(page).to have_content 'Account'
  end

  scenario 'with blank name' do
    sign_up_with('', 'drthhlmt@spaceballone.com')
    #User should be redirected to the sign up page
    expect(current_path).to match new_user_registration_path
  end
end

feature 'Returning visitor can reauthenticate' do
  scenario 'signs up, logs out, logs in' do
    user = create(:user) 
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    #TODO Make this be configurable/automagic?
    fill_in 'user_password', with: 'password'
    click_button 'Sign in'
    expect(current_path).to eq root_path
    expect(page).to have_content 'Schedule tea time'
  end
end


private
def sign_up_with(name, email, opts = nil)
  visit root_path
  fill_in 'user_name', with: name
  fill_in 'user_email', with: email
  select(City.first.name, from: 'city')
  click_button "Let's Get Tea"
end
