require "test_helper"

class NullBorrowPolicyTest < ActiveSupport::TestCase
  setup do
    @policy = NullBorrowPolicy.new
  end

  test "borrow policy API" do
    assert_equal false, @policy.member_renewable?
    assert_equal 0, @policy.maximum_items_per_member
    refute @policy.limit_items_per_member?
  end
end
