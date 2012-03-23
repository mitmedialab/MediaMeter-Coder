require 'test_helper'

class GoldsControllerTest < ActionController::TestCase
  setup do
    @gold = golds(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:golds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gold" do
    assert_difference('Gold.count') do
      post :create, gold: @gold.attributes
    end

    assert_redirected_to gold_path(assigns(:gold))
  end

  test "should show gold" do
    get :show, id: @gold.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gold.to_param
    assert_response :success
  end

  test "should update gold" do
    put :update, id: @gold.to_param, gold: @gold.attributes
    assert_redirected_to gold_path(assigns(:gold))
  end

  test "should destroy gold" do
    assert_difference('Gold.count', -1) do
      delete :destroy, id: @gold.to_param
    end

    assert_redirected_to golds_path
  end
end
