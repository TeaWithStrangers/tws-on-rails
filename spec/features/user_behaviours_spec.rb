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
    expect(current_path).to match sign_up_path
  end

  scenario 'can sign up, log out, log in' do
    user = create(:user) 
    sign_in user
    expect(current_path).to eq schedule_city_path(user.home_city)
    expect(page).to have_content user.home_city.name
  end

  scenario 'with an already created user account from a registration form' do
    user = create(:user)
    sign_up_with(user.nickname, user.email)
    #Should redirect to login page with an alert
    expect(current_path).to eq new_user_session_path
    #TODO: Add check for Flash message once it's merged
  end
end
feature 'Registered User' do
  before(:each) do
    @host = create(:user, :host)
    @user = create(:user, home_city: @host.home_city)
    @tt = create(:tea_time, host: @host, city: @host.home_city)
    sign_in @user
  end

  feature 'Tea Time Attendance' do
    scenario 'allows a user to sign up' do
      visit city_path(@user.home_city)
      expect(page.status_code).to eq(200)
      click_link('5 spots left')
      expect(current_path).to eq tea_time_path(@tt)

      find('input.confirm').click
      expect(@user.attendances.map(&:tea_time)).to include @tt
    end

    scenario 'logged out user with account tries to attend' do
      sign_out
      visit city_path(@user.home_city)
      # Should be redirected to the new TWS Sign up experience
      expect(current_path).to eq root_path
    end

    scenario 'user can flake' do
      attend_tt(@tt)
      visit profile_path
      click_link 'Cancel my spot'
      fill_in :attendance_reason, with: 'flake-y'
      click_button 'Cancel my spot'
      expect(@user.attendances.reload.first.flake?).to eq true
      expect(@user.attendances.reload.first.reason).to eq 'flake-y'
      #Shouldn't show a flaked TT on Profile page
      expect(page).not_to have_content @tt.friendly_time
    end
  end

  feature 'History' do
    before(:each) do
      @old_tt = create(:tea_time, :past)
      create(:attendance, user: @user, tea_time: @old_tt)
    end
    scenario 'user can see their history' do
      visit history_path
      expect(page).to have_content @old_tt.friendly_time
    end

    #TODO: This should probably be a unit test
    scenario 'can be viewed even if another user has deleted their account' do
      deleted_att = build(:attendance, tea_time: @old_tt, user: nil)
      deleted_att.save!(validate: false)
      visit history_path
      expect(page).to have_content @old_tt.friendly_time
      expect(page).to have_content User.nil_user.name
    end
  end

  feature 'Waitlist' do
    before(:each) do
      @full_tt = create(:tea_time, :full)
    end

    scenario 'user can add himself to the waitlist for a full tea time' do
      attend_tt(@full_tt)
      expect(@user.attendances.reload.first.waiting_list?).to eq true
    end

    scenario 'user is informed when someone on the waitlist flakes' do
      attend_tt(@full_tt)
      expect(@user.attendances.reload.first.waiting_list?).to eq true
      @full_tt.attendances.where.not(user_id: @user.id).sample.flake!
      expect(ActionMailer::Base.deliveries.map(&:subject)).to include('A spot just opened up at tea time! Sign up!')
    end
  end
end

private
  def sign_up_with(name, email, opts = nil)
    visit sign_up_path
    fill_in 'user_nickname', with: name
    fill_in 'user_email', with: email
    fill_in 'user_password', with: SecureRandom.hex
    click_button "Let's Go!"
  end

  def attend_tt(tea_time)
    visit tea_time_path(tea_time)
    find(:css, 'input.confirm').click
    expect(@user.attendances.reload.map(&:tea_time)).to include tea_time
  end
