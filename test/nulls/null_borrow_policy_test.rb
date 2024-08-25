require "test_helper"

class NullBorrowPolicyTest < ActiveSupport::TestCase
  setup do
    @policy = NullBorrowPolicy.new
  end

  test "borrow policy API" do
    assert_equal false, @policy.member_renewable?
  end
end
