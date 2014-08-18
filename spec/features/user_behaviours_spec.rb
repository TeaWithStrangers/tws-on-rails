require 'spec_helper'

feature 'Signing In & Up' do
  before(:all) do
    create(:city)
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

  scenario 'can sign up, log out, log in' do
    user = create(:user) 
    sign_in user
    expect(current_path).to eq root_path
    expect(page).to have_content 'Schedule tea time'
  end

  scenario 'with an already created user account from a registration form' do
    user = create(:user)
    sign_up_with(user.name, user.email)
    #Should redirect to login page with an alert
    expect(current_path).to eq new_user_session_path
    #TODO: Add check for Flash message once it's merged
  end
end

feature 'Tea Time Attendance' do
  before(:all) do
    @host = create(:user, :host)
    @user = create(:user, home_city: @host.home_city)
    @tt = create(:tea_time, host: @host, city: @host.home_city)
  end

  scenario 'allows a user to sign up' do
    sign_in @user
    visit city_path(@user.home_city)
    expect(page.status_code).to eq(200)
    click_link('5 spots left')
    expect(page).to have_content @host.name
    click_button 'Confirm'
    expect(@user.attendances.map(&:tea_time)).to include @tt
  end

  scenario 'logged out user with accounts tries to attend' do
    visit city_path(@user.home_city)
    click_link('5 spots left')
    fill_in :name, with:  @user.name
    fill_in :email, with: @user.email
    click_button 'Confirm'
    expect(current_path).to eq new_user_session_path
  end

  scenario 'user can flake' do
    sign_in @user
    attend_tt(@user, @tt)
    visit profile_path
    click_button 'Cancel my spot'
    expect(@user.attendances.reload.first.flake?).to eq true
    #Shouldn't show a flaked TT on Profile page
    expect(page).not_to have_content @tt.friendly_time
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

  def attend_tt(user, tea_time)
    visit tea_time_path(tea_time)
    click_button 'Confirm'
    expect(@user.attendances.map(&:tea_time)).to include @tt
  end
