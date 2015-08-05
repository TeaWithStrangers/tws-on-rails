require 'spec_helper'
include ControllerHelpers

describe TeaTimesController do
  before(:all) do
    @user = create(:user)
    @host = create(:user, :host)
    @admin = create(:user, :admin)
  end

  describe '#index' do
    context 'viewed by a host or admin' do
      it 'should show *all* the tea times to hosts' do
        sign_in @host
        get :index
        expect(assigns(:tea_times)).to eq(TeaTime.all)
      end

      it 'should show *all* the tea times to admins' do
        sign_in @admin
        get :index
        expect(assigns(:tea_times)).to eq(TeaTime.all)
      end
    end

    it 'should redirect normal and anonymous users to sign in' do
      get :index
      assert_response :redirect

      sign_in @user
      referer '/'
      get :index
      assert_response 302
    end
  end

  describe '#show' do
    before(:all) do
      @tt = create(:tea_time)
    end

    it 'should assign and display a tea time' do
      sign_in @user
      referer '/'
      get :show, {id: @tt}
      expect(assigns(:tea_time)).to eq @tt
      assert_response :success
    end

    it 'should 404 for a deleted tea time' do
      @tt.delete
      expect { get :show, {id: @tt} }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#update' do
    before(:each) do
      @tt = create(:tea_time, host: @host)
      @hsh = {location: 'Somewhere Else'}
      sign_in @host
    end

    it 'host should be able to update the tea time' do
      patch :update, id: @tt, tea_time: @hsh
      expect(@tt.reload.location).to eq(@hsh[:location])
    end

    it 'user should not be able to update and be redirected' do
      referer '/profile'
      sign_in @user
      loc = @tt.location
      patch :update, id: @tt, tea_time: @hsh
      expect(@tt.reload.location).to eq(loc)
      assert_response :redirect
    end
  end

  describe '#cancel' do
    before(:each) do
      @tt = create(:tea_time, host: @host)
      sign_in @host
    end

    it 'should be cancelled' do
      put :cancel, id: @tt
      expect(@tt.reload.cancelled?).to eq true
    end
  end

  describe '#destroy' do
    before(:each) do
      @tt = create(:tea_time, host: @host)
      sign_in @host
    end

    it 'should not be possible (through the site)' do
      delete :destroy, {id: @tt}
      expect(TeaTime.exists?(@tt)).to eq true
    end
  end
end
