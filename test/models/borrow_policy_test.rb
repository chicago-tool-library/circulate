require "test_helper"

class BorrowPolicyTest < ActiveSupport::TestCase
  [
    :borrow_policy,
    [:borrow_policy, :requires_approval],
    :member_renewable_borrow_policy,
    :unnumbered_borrow_policy,
    :consumable_borrow_policy,
    :default_borrow_policy
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      borrow_policy = build(*factory_name)
      borrow_policy.valid?
      assert_equal({}, borrow_policy.errors.messages)
    end
  end

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
