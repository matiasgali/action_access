require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  test "any access with no clearance level gets redirected" do
    # Undefined role
    get :new
    assert_redirected_to root_url

    post :create
    assert_redirected_to root_url
  end

  test "any access with undefined clearance level gets redirected" do
    # The role doesn't exist (undefined)
    get :new, nil, {role: :super}
    assert_redirected_to root_url

    post :create, nil, {role: :super}
    assert_redirected_to root_url
  end

  test "any unauthorized access gets redirected" do
    # The roles exist but aren't authorized.
    get :new, nil, {role: :user}
    assert_redirected_to root_url

    post :create, nil, {role: :editor}
    assert_redirected_to root_url
  end

  test "authorized accesses aren't redirected" do
    get :new, nil, {role: :admin}        # Admins can create articles
    assert_response :success

    get :edit, {id: 1}, {role: :editor}  # Editors can edit articles
    assert_response :success

    get :show, {id: 1}, {role: :user}    # Users can view articles
    assert_response :success
  end
end
