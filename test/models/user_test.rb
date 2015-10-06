require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "the model gets extended" do
    assert user.respond_to? :can?
  end

  test "it allows to check permissions" do
    # User
    assert user.can?(:show, :articles)
    assert_not user.can?(:create, :articles)

    # Admin
    assert admin.can?(:show, :articles)
    assert admin.can?(:create, :articles)
  end

  test "users can have more than one role" do
    # Assert the mixed user is both an 'editor' and a 'cleaner'
    assert mixed.can?(:show, :articles)     # Editors and cleaners
    assert mixed.can?(:edit, :articles)     # Editors only
    assert mixed.can?(:destroy, :articles)  # Cleaners only

    # Assert the mixed user is not an 'admin'
    assert_not mixed.can?(:new, :articles)
    assert_not mixed.can?(:create, :articles)
  end


  private

    def admin
      @admin ||= User.where({ username: 'flynn', roles: 'admin' }).first_or_create
    end

    def mixed
      @mixed ||= User.where({ username: 'clu', roles: 'editor,cleaner' }).first_or_create
    end

    def user
      @user ||= User.where({ username: 'sam', roles: 'user' }).first_or_create
    end
end
