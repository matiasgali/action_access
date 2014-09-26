require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @admin ||= User.where({ username: 'flynn', role: 'admin' }).first_or_create
    @user  ||= User.where({ username: 'sam', role: 'user' }).first_or_create
  end

  test "the model gets extended" do
    assert @user.respond_to? :can?
  end

  test "it allows to check permissions" do
    # User
    assert @user.can?(:show, :articles)
    assert_not @user.can?(:create, :articles)

    # Admin
    assert @admin.can?(:create, :articles)
    assert @admin.can?(:edit, :articles)
  end
end
