require 'spec_helper'

feature 'Signing In & Up' do
  before(:all) do
    create(:city)
  end

  scenario 'with valid email and password' do
    sign_up_with('Darth Helmet', 'drthhlmt@spaceballone.com')
    expect(page).to have_content 'Dashboard'
  end

  scenario 'can sign up with a valid email and password and a redirect_to_tt path' do
    tt = create(:tea_time)
    visit sign_up_path(redirect_to_tt: tt.id)
    fill_in('user_name', with: 'Darth Helmet')
    fill_in('user_email', with: 'drthhlmt@spaceballone.com')
    fill_in('user_password', with: SecureRandom.hex)
    click_button("Let's Get Tea")
    expect(page.current_path).to eq tea_time_path(tt.id)
  end

  scenario 'can sign up with a valid email and password and be shown a remind_next_month banner' do
    visit sign_up_path(remind_next_month: 'yes')
    fill_in('user_name', with: 'Darth Helmet')
    fill_in('user_email', with: 'drthhlmt@spaceballone.com')
    fill_in('user_password', with: SecureRandom.hex)
    click_button("Let's Get Tea")
    expect(page.current_path).to eq tea_times_path
    expect(page).to have_content "next month"
  end

  scenario 'can sign up with a valid email and password and selected home city' do
    city = create(:city)

    # Load the signup page and set the city to be selected by default
    visit sign_up_path(city_id: city.id)

    # Check the city is selected by default
    expect(page).to have_select('user_home_city', selected: city.name)

    fill_in('user_name', with: 'Darth Helmet')
    fill_in('user_email', with: 'drthhlmt_city@spaceballone.com')
    fill_in('user_password', with: SecureRandom.hex)
    click_button("Let's Get Tea")
    expect(page.current_path).to eq tea_times_path

    # Check that the city was saved
    user = User.find_by_email('drthhlmt_city@spaceballone.com')
    expect(user.home_city).to eq city
  end

  scenario 'can sign up with a valid email and password and other home city' do
    visit sign_up_path()
    fill_in('user_name', with: 'Darth Helmet')
    fill_in('user_email', with: 'drthhlmt_city@spaceballone.com')
    fill_in('user_password', with: SecureRandom.hex)

    # Select other city
    select('Other', from: 'user_home_city')

    click_button("Let's Get Tea")
    expect(page.current_path).to eq tea_times_path

    # Check that the city is nil
    user = User.find_by_email('drthhlmt_city@spaceballone.com')
    expect(user.home_city).to eq nil
  end

  scenario 'with blank name' do
    sign_up_with('', 'drthhlmt@spaceballone.com')
    #User should be redirected to the sign up page
    expect(current_path).to match sign_up_path
  end

  scenario 'can sign up, log out, log in' do
    user = create(:user)
    sign_in user
    expect(current_path).to eq tea_times_path
  end

  scenario 'can sign in with a redirect_to_tt path and be redirected correctly' do
    tt = create(:tea_time)
    user = create(:user)
    visit new_user_session_path(redirect_to_tt: tt.id)
    sign_in user
    expect(page.current_path).to eq tea_time_path(tt.id)
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
      click_link('Sign me up')
      expect(current_path).to eq tea_time_path(@tt)

      find('input.confirm').click
      expect(@user.attendances.map(&:tea_time)).to include @tt
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
      expect(page).to have_content @old_tt.date_sans_year
    end

    #TODO: This should probably be a unit test
    scenario 'can be viewed even if another user has deleted their account' do
      deleted_att = build(:attendance, tea_time: @old_tt, user: nil)
      deleted_att.save!(validate: false)
      visit history_path
      expect(page).to have_content @old_tt.date_sans_year
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

feature 'Registered User without home city' do
  before(:each) do
    @host = create(:user, :host)
    @user = create(:user, home_city: nil)
    @tt = create(:tea_time, host: @host, city: @host.home_city)
    sign_in @user
  end

  feature 'Tea Time Attendance' do
    scenario 'signing up to a tea time sets user home city to tea time city' do
      visit city_path(@host.home_city)
      expect(page.status_code).to eq(200)
      click_link('Sign me up')
      expect(current_path).to eq tea_time_path(@tt)

      find('input.confirm').click

      # Reload the user model and check the user's home city is set
      @user.reload
      expect(@user.home_city).to eq @tt.city
    end
  end
end

private
  def sign_up_with(name, email, opts = nil)
    visit sign_up_path
    fill_in('user_name', with: name)
    fill_in('user_email', with: email)
    fill_in('user_password', with: SecureRandom.hex)
    click_button("Let's Get Tea")
  end

  def attend_tt(tea_time)
    visit tea_time_path(tea_time)
    find(:css, 'input.confirm').click
    expect(@user.attendances.reload.map(&:tea_time)).to include tea_time
  end
