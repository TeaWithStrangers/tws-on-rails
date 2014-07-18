require 'spec_helper'

describe HostsController do
  describe '#create' do

    before(:each) do
      admin = create(:user)
      admin.roles << Role.find_by(name: 'Admin')

      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in(admin)
      controller.stub(:needs_password?) { false }
    end

    let(:host_email) { 'johnnyenglish@mrbean.com' }
    let(:params) do
      {
        name: 'Mr. Bean',
        email: 'johnnyenglish@mrbean.com',
        home_city_id: create(:city).id
      }
    end

    context 'user does not exist' do
      it 'should create a new user and assign a host to it' do
        # expect that user doesn't exist
        expect(User.find_by(email: host_email)).to be_nil
        # create host
        post 'create', user: params
        # expect that user exists
        new_user = User.find_by(email: host_email)
        expect(new_user).to_not be_nil
        expect(new_user.roles.map(&:name)).to include("Host")
      end
    end

    context 'user already exists' do
      it 'should find existing user and assign a host role to it' do
        # create the user first
        user = create(:user, email: host_email)

        # expect that user exists but does not have host params
        expect(user.roles.map(&:name)).not_to include("Host")

        post 'create', user: params

        user.reload
        expect(user.roles.map(&:name)).to include("Host")
      end
    end
  end
end