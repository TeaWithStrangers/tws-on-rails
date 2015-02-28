require 'spec_helper'

describe HostsController do
  describe '#create' do
    before(:each) do
      admin = create(:user, :admin)

      sign_in(admin)
      controller.stub(:needs_password?) { false }
    end

    let(:host_email) { 'johnnyenglish@mrbean.com' }
    let(:params) do
      {
        name: 'Mr. Bean',
        email: 'johnnyenglish@mrbean.com',
        home_city_id: create(:city)
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
        expect(new_user.roles).to include(:host)
      end
    end

    context 'user already exists' do
      let(:user) { create(:user, email: host_email) }
      it 'should find existing user and assign a host role to it' do
        # create the user first
        # expect that user exists but does not have host params
        expect(user.roles).not_to include(:host)

        post 'create', user: params

        user.reload
        expect(user.roles).to include(:host)
      end

      it 'should leave the passwords of current users alone' do
        current_pw = user.password
        post 'create', user: params

        user.reload
        expect(user.password).to eq(current_pw)
      end
    end

  end

  describe '#new' do
    it 'should redirect anonymous users to sign in' do
      get :new
      assert_response :redirect
    end

    context 'user is not an admin' do
      it 'should be unauthorized' do
        user = create(:user)
        sign_in user

        get :new
        expect(response).to redirect_to({:controller => :static, :action => :index})
      end

      it 'should not allow hosts' do
        user = create(:user, :host)
        sign_in user

        get :new

        expect(response).to redirect_to({:controller => :static, :action => :index})
      end
    end
  end

  describe '#show' do
    let(:host) { create(:user, :host) }

    it 'should show the host' do
      get :show, {id: host.home_city, host_id: host}

      expect(assigns(:host)).to eq(host)
      expect(assigns(:city)).to eq(host.home_city)

      assert_response :success
    end

  end
end
