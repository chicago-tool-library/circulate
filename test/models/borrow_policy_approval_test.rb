require "test_helper"

class BorrowPolicyApprovalTest < ActiveSupport::TestCase
  [
    :borrow_policy_approval,
    %i[borrow_policy_approval approved],
    %i[borrow_policy_approval rejected],
    %i[borrow_policy_approval requested],
    %i[borrow_policy_approval revoked]
  ].each do |factory_name|
    test "#{Array(factory_name).join(", ")} is a valid factory/trait" do
      borrow_policy_approval = build(*factory_name)
      borrow_policy_approval.valid?
      assert_equal({}, borrow_policy_approval.errors.messages)
    end
  end

  test "validations" do
    borrow_policy_approval = BorrowPolicyApproval.new

    borrow_policy_approval.status = nil

    refute borrow_policy_approval.save

    assert_equal ["must exist"], borrow_policy_approval.errors[:borrow_policy]
    assert_equal ["must exist"], borrow_policy_approval.errors[:member]
    assert_equal ["is not included in the list"], borrow_policy_approval.errors[:status]

    borrow_policy_approval.status = "foo"

    refute borrow_policy_approval.save

    assert_equal ["is not included in the list"], borrow_policy_approval.errors[:status]

    existing_borrow_policy_approval = create(:borrow_policy_approval, :approved)

    borrow_policy_approval.member = existing_borrow_policy_approval.member
    borrow_policy_approval.borrow_policy = existing_borrow_policy_approval.borrow_policy

    refute borrow_policy_approval.save

    assert_equal ["has already been taken"], borrow_policy_approval.errors[:borrow_policy_id]
  end
end
