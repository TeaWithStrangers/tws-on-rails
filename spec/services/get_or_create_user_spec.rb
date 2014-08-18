require 'spec_helper.rb'

describe GetOrCreateUser do
  context '#call' do
    let(:params) { {email: 'barf@eagle5.com', name: 'Barf'} } 
    let(:city) { create(:city) }
    let!(:returned) { GetOrCreateUser.call(params, city) }

    it 'should accept params and a city and return a matching user' do
      u = returned[:user]
      expect(u.name).to eq params[:name]
      expect(u.email).to eq params[:email]
    end

    it 'should have :new_user? as true for a created user' do
      expect(returned[:new_user?]).to eq true
    end

    it 'should have :new_user? as false for an existing user' do
      second = GetOrCreateUser.call(params, city)
      expect(second[:new_user?]).to eq false
    end
  end
end
