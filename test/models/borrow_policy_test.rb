require "test_helper"

class BorrowPolicyTest < ActiveSupport::TestCase
  test "sets other borrow policies to not be default" do
    old_policy = BorrowPolicy.create!(name: "Old", code: "O", default: true)
    assert old_policy.reload.default

    new_policy = BorrowPolicy.create!(name: "New", code: "N", default: true)
    assert new_policy.reload.default
    refute old_policy.reload.default
  end

  test "allow_multiple_holds_per_member? is true when uniquely_numbered is false" do
    policy = BorrowPolicy.new(uniquely_numbered: false)

    assert policy.allow_multiple_holds_per_member?
  end

  test "allow_one_holds_per_member? is true when uniquely_numbered is true" do
    policy = BorrowPolicy.new(code: true)

    assert policy.allow_one_holds_per_member?
  end

  test "requires consumables to not be uniquely_numbered" do
    policy = BorrowPolicy.new(uniquely_numbered: true, consumable: true)

    refute policy.valid?

    assert_equal ["must not be enabled for consumables"], policy.errors[:uniquely_numbered]
  end
end
