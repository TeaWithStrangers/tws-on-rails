require 'spec_helper'

feature 'Hosting: ' do
  background do
    @city = create(:city)
    @u = create(:user, :host, home_city: @city)
    sign_in @u
  end

  feature 'creating a tea time' do
    scenario 'with valid info' do
      expect(@u.tea_times.count).to eq 0
      create_tea_time({location: 'Spaceball One'})
      expect(@u.tea_times.count).to eq 1
      expect(@u.tea_times.first.location).to eq 'Spaceball One'
      expect(page).to have_content @u.tea_times.first.friendly_time
    end

    scenario 'updating tea time' do
      create_tea_time
      visit edit_tea_time_path(@u.tea_times.first)
      fill_in :tea_time_location, with: 'Vega'
      click_button 'Update Tea Time'
      expect(page).to have_content 'Vega'
      expect(@u.tea_times.first.location).to eq 'Vega'
    end

    scenario 'changing tea time host' do
      @new_host = create(:user, :host)
      create_tea_time
      visit edit_tea_time_path(@u.tea_times.first)
      tt = @u.tea_times.first
      find('#tea_time_user_id').find(:xpath, "option[@value=#{@new_host.id}]").select_option
      click_button 'Update Tea Time'

      #TT should now belong to new host
      expect(@new_host.tea_times).to include(tt)
      expect(@u.tea_times).to eq([])
    end
  end
end


private

def create_tea_time(opts = {})
  time = opts[:start_time] || Time.now + 1.day 
  location = opts[:location] || 'Druidia'
  city = opts[:city] || City.first.name

  visit new_tea_time_path
  select_date_and_time time, from: [:tea_time, :start_time]
  fill_in :tea_time_location, with: location
  click_button 'Create Tea Time'
end
