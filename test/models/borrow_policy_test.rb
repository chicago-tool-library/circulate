require "test_helper"

class BorrowPolicyTest < ActiveSupport::TestCase
  test "sets other borrow policies to not be default" do
    old_policy = BorrowPolicy.create!(name: "Old", code: "O", default: true)
    assert old_policy.reload.default

    new_policy = BorrowPolicy.create!(name: "New", code: "N", default: true)
    assert new_policy.reload.default
    refute old_policy.reload.default
  end
end
