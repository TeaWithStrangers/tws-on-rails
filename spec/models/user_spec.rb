require 'spec_helper'

describe 'User' do
  it 'is not valid without a home city' do
    user = User.create
    expect(user.errors.messages.keys).to include :home_city_id
    expect(user.errors.messages[:home_city_id]).to include "can't be blank"
  end

  context 'roles' do
    let(:admin) { create(:user, :admin) }
    let(:host) { create(:user, :host) }
    let(:user) { create(:user) }

    describe '.admin?' do
      it 'should return false for non-admins' do
        expect(host.admin?).to eq(false)
        expect(user.admin?).to eq(false)
      end

      it 'should return true for an admin' do
        expect(admin.admin?).to eq(true)
      end
    end

    describe '.host?' do
      it 'should return true for an admin' do
        expect(admin.host?).to eq(true)
      end

      it 'should return true for an host' do
        expect(host.host?).to eq(true)
      end
    end
  end
end
