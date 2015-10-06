require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  # Test that the :all keyword works properly
  test "anyone can do anything" do
    get :home, nil, {roles: :admin}
    assert_response :success

    get :home, nil, {roles: :undefined}
    assert_response :success

    get :home
    assert_response :success
  end
end
