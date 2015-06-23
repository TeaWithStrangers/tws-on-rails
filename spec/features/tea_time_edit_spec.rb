require 'spec_helper'

feature 'Editing tea times' do
  scenario 'deleting attendances' do
    city = create(:city)
    user  = create(:user, :host, home_city_id: city.id)
    user.roles << :host
    tt    = create(:tea_time, city_id: city.id, user_id: user.id)
    attendance = create(:attendance, tea_time_id: tt.id)
    expect(tt.attendances.count).to eq 1
    expect(attendance.status).to eq "pending"
    sign_in(user)
    visit edit_tea_time_path(tt.id)
    click_link("cancel-attendance")
    tt.reload
    attendance.reload
    expect(tt.attendances.count).to eq 1
    expect(attendance.status).to eq "flake"
    expect(current_path).to eq edit_tea_time_path(tt.id)
  end
end