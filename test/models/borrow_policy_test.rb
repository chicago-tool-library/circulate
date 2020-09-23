require "test_helper"

class BorrowPolicyTest < ActiveSupport::TestCase
  test "sets other borrow policies to not be default" do
    old_policy = BorrowPolicy.create!(name: "Old", code: "O", default: true)
    assert old_policy.reload.default

    new_policy = BorrowPolicy.create!(name: "New", code: "N", default: true)
    assert new_policy.reload.default
    refute old_policy.reload.default
  end

  test "allow_multiple_holds_per_member? is true when the code is 'A'" do
    policy = BorrowPolicy.new(code: "A")

    assert policy.allow_multiple_holds_per_member?
  end

  test "allow_one_holds_per_member? is true when code is not 'A'" do
    policy = BorrowPolicy.new(code: "B")

    assert policy.allow_one_holds_per_member?
  end
end
