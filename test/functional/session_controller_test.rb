require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  test "create a new user session" do

    post :create
    assert_redirected_to :controller=>:session, :action=>:new

    assert_no_difference('User.count') do
      assert_equal nil, session[:username]
      post :create, {:username=>"bob"}
      assert_equal "bob", session[:username]
      assert_redirected_to :controller=>:code, :action=>:generic_one
    end

    assert_difference('User.count') do
      session[:username] = nil
      post :create, {:username=>"rahul"}
      assert_equal "rahul", session[:username]
      assert_redirected_to :controller=>:code, :action=>:generic_one
    end

  end
end
