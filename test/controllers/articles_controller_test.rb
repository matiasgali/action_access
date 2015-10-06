require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  test "accesses with no clearance level get redirected" do
    # Undefined role
    get :new
    assert_redirected_to root_url

    post :create
    assert_redirected_to root_url
  end

  test "accesses with undefined clearance level get redirected" do
    # The role doesn't exist (haven't been defined)
    get :new, nil, {roles: :root}
    assert_redirected_to root_url

    post :create, nil, {roles: :root}
    assert_redirected_to root_url
  end

  test "unauthorized accesses get redirected" do
    # The roles exist but aren't authorized.
    post :create, nil, {roles: :editor}
    assert_redirected_to root_url

    get :edit, {id: 1}, {roles: :user}
    assert_redirected_to root_url
  end

  test "authorized accesses aren't redirected" do
    get :new, nil, {roles: :admin}
    assert_response :success

    get :edit, {id: 1}, {roles: :editor}
    assert_response :success
  end

  test "many clearance levels can be defined in one statement" do
    get :index, nil, {roles: :editor}
    assert_response :success

    get :index, nil, {roles: :cleaner}
    assert_response :success

    get :index, nil, {roles: :user}
    assert_response :success
  end

  test "users can have many clearance levels" do
    post :create, nil, {roles: [:editor, :cleaner]}
    assert_redirected_to root_url

    get :index, nil, {roles: [:editor, :cleaner]}
    assert_response :success

    get :edit, {id: 1}, {roles: [:editor, :cleaner]}
    assert_response :success

    delete :destroy, {id: 1}, {roles: [:editor, :cleaner]}
    assert_redirected_to articles_url
  end
end
