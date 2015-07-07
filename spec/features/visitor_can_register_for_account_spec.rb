require 'spec_helper'

feature 'Signing up for account' do
  scenario 'Set given_name to nickname' do
    visit sign_up_path
    email = "John@JohnISCool.com"
    fill_in('user_name', with: 'John')
    fill_in('user_email', with: email)
    fill_in('user_password', with: 'secret1234')
    click_button("Let's Get Tea")
    expect(User.find_by(email: email.downcase).given_name).to eq "John"
  end
end