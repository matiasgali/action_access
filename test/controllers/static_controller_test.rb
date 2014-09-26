require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  # Test that the :all key works properly
  test "anyone can do anything" do
    get :home, nil, {role: :admin}
    assert_response :success

    get :home, nil, {role: :undefined}
    assert_response :success

    get :home
    assert_response :success
  end
end
