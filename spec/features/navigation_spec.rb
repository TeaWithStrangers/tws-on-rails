require 'spec_helper'

feature 'Header navigation links' do
  scenario 'Non signed in user' do
    visit root_path
    expect(page.find('header nav')).to have_link('Hosting')
  end
end
