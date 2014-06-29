require 'spec_helper'

describe 'User' do
  it 'is not valid without a home city' do
    user = User.create
    expect(user.errors.messages.keys).to include :home_city_id
    expect(user.errors.messages[:home_city_id]).to include "can't be blank"
  end
end