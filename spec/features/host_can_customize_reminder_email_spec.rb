require 'spec_helper'

feature 'Customizing reminder email' do
  scenario 'Navigating from profile page' do
    host = create(:user, :host)
    sign_in(host)
    visit profile_path
    click_on("Customize Reminders")
    expect(current_path).to eq '/profile/customize_reminder_email'
  end
end
