require 'spec_helper'

describe RegistrationsController do
  describe 'update' do
    it 'should be able to update twitter and facebook attributes' do
      user = create(:user)
      expect(user.twitter).to eq nil

      @request.env["devise.mapping"] = Devise.mappings[:user]
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