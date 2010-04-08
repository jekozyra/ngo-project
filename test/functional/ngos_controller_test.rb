require 'test_helper'

class NgosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ngos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ngo" do
    assert_difference('Ngo.count') do
      post :create, :ngo => { }
    end

    assert_redirected_to ngo_path(assigns(:ngo))
  end

  test "should show ngo" do
    get :show, :id => ngos(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ngos(:one).to_param
    assert_response :success
  end

  test "should update ngo" do
    put :update, :id => ngos(:one).to_param, :ngo => { }
    assert_redirected_to ngo_path(assigns(:ngo))
  end

  test "should destroy ngo" do
    assert_difference('Ngo.count', -1) do
      delete :destroy, :id => ngos(:one).to_param
    end

    assert_redirected_to ngos_path
  end
end
