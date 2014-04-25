require 'test_helper'

class TeaTimesControllerTest < ActionController::TestCase
  setup do
    @tea_time = tea_times(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tea_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tea_time" do
    assert_difference('TeaTime.count') do
      post :create, tea_time: {  }
    end

    assert_redirected_to tea_time_path(assigns(:tea_time))
  end

  test "should show tea_time" do
    get :show, id: @tea_time
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tea_time
    assert_response :success
  end

  test "should update tea_time" do
    patch :update, id: @tea_time, tea_time: {  }
    assert_redirected_to tea_time_path(assigns(:tea_time))
  end

  test "should destroy tea_time" do
    assert_difference('TeaTime.count', -1) do
      delete :destroy, id: @tea_time
    end

    assert_redirected_to tea_times_path
  end
end
