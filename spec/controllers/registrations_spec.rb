require 'spec_helper'

describe RegistrationsController do
  before(:each) {
    @request.env["devise.mapping"] = Devise.mappings[:user]
  }
  describe '#create' do
    let(:params) {
      {email: 'foo@foobar.com', password: 'password',
       nickname: 'Baz'}
    }

    it 'should create a new non-waitlisted user and log them in' do
      post 'create', user: params
      u = User.find_by(email: 'foo@foobar.com')
      expect(u).not_to eq nil
      expect(u.waitlisted?).to eq false
      expect(response).to redirect_to(cities_path)
    end
  end

  describe 'update' do
    let(:user) { create(:user) }

    before(:each) do
      sign_in user
      controller.stub(:needs_password?) { false }
    end

    it 'should be able to update twitter and facebook attributes' do
      expect(user.twitter).to eq nil

      params = { twitter: 'foo', facebook: 'bar' }
      put 'update', user: params

      user.reload
      expect(user.twitter).to eq 'foo'
      expect(user.facebook).to eq 'bar'
    end

    it 'should redirect the user to their profile' do
      put 'update', user: { twitter: 'foo' }
      expect(response).to redirect_to(profile_path)
    end
  end
end
