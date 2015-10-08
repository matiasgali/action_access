require 'test_helper'
require 'support/compact_environment'

class ActionAccessTest < ActiveSupport::TestCase
  test "unauthorized accesses aren't allowed" do
    assert_equal false, keeper.lets?(:user, :edit, :posts)
    assert_equal false, keeper.lets?(:user, :edit, :posts, namespace: :admin)
  end

  test "authorized accesses are allowed" do
    keeper.let :editor, [:edit, :update], :posts
    assert_equal true, keeper.lets?(:editor, :edit, :posts)
    assert_equal true, keeper.lets?(:editor, :update, :posts)
  end

  test "authorized accesses within namespaces are allowed" do
    keeper.let :admin, [:new, :create], :posts, namespace: :admin
    assert_equal true, keeper.lets?(:admin, :new, :posts, namespace: :admin)
    assert_equal true, keeper.lets?(:admin, :create, :posts, namespace: :admin)
  end
end
