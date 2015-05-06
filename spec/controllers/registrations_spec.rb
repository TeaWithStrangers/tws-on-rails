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

    it 'should create a new user and log them in' do
      post 'create', user: params
      u = User.find_by(email: 'foo@foobar.com')
      expect(u).not_to eq nil
      expect(u.waitlisted?).to eq true
      expect(response).to redirect_to(cities_path)
    end
  end
  describe 'update' do
    it 'should be able to update twitter and facebook attributes' do
      user = create(:user)
      expect(user.twitter).to eq nil

      sign_in user

      controller.stub(:needs_password?) { false }

      params = { twitter: 'foo', facebook: 'bar' }
      put 'update', user: params

      user.reload
      expect(user.twitter).to eq 'foo'
      expect(user.facebook).to eq 'bar'
    end
  end
end
