require 'test_helper'

class SecretsControllerTest < ActionController::TestCase
  test "controllers are locked by default" do
    # Test that the "lock_access" call in ApplicationController works properly.
    # There are no access rules in SecretsController but it should be locked anyway.
    get :index, nil, {roles: :admin}
    assert_redirected_to root_url

    get :index, nil, {roles: :editor}
    assert_redirected_to root_url

    get :index
    assert_redirected_to root_url
  end
end
