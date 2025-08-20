require "application_system_test_case"

module Account
  class HoldsTest < ApplicationSystemTestCase
    setup do
      @member = create(:verified_member_with_membership, created_at: 1.year.ago)
      login_as @member.user
    end

    test "placing a hold on an item that doesn't require approval" do
      borrow_policy = create(:borrow_policy)
      item = create(:item, borrow_policy:)

      visit item_path(item)

      assert_text "You can place this item on hold"

      assert_difference("Hold.count", 1) do
        click_on "Place a hold"
      end

      assert_text "Hold placed."

      hold = Hold.first!

      assert_equal item, hold.item
      assert_equal @member, hold.member
    end

    test "requesting approval to place a hold on an item that does require approval" do
      borrow_policy = create(:borrow_policy, :requires_approval)
      item = create(:item, borrow_policy:)

      visit item_path(item)

      assert_text "This is a C-Tool and requires staff approval. New members and unreliable borrowers do not have access to this tool."
      refute_text "Place a hold"

      assert_difference("BorrowPolicyApproval.count", 1) do
        click_on "Request approval"
        assert_text "Approval requested."
      end

      borrow_policy_approval = BorrowPolicyApproval.first!

      assert_equal borrow_policy, borrow_policy_approval.borrow_policy
      assert_equal @member, borrow_policy_approval.member
      assert_equal "requested", borrow_policy_approval.status
    end

    test "trying to create a hold on an item that requires approval but approval hasn't been approved" do
      borrow_policy = create(:borrow_policy, :requires_approval)
      item = create(:item, borrow_policy:)
      create(:borrow_policy_approval, :requested, borrow_policy:, member: @member)

      visit item_path(item)

      assert_text "You have requested access to borrow C-Tools."
      refute_text "Place a hold"
    end

    test "trying to create a hold on an item that requires approval but approval has been rejected" do
      borrow_policy = create(:borrow_policy, :requires_approval)
      item = create(:item, borrow_policy:)
      create(:borrow_policy_approval, :rejected, borrow_policy:, member: @member)

      visit item_path(item)

      assert_text "This is a C-Tool and requires staff approval to borrow. New members and unreliable borrowers do not have access to C-Tools."
      refute_text "Place a hold"
    end

    test "trying to create a hold on an item that requires approval but approval has been revoked" do
      borrow_policy = create(:borrow_policy, :requires_approval)
      item = create(:item, borrow_policy:)
      create(:borrow_policy_approval, :revoked, borrow_policy:, member: @member)

      visit item_path(item)

      assert_text "This is a C-Tool and requires staff approval to borrow. New members and unreliable borrowers do not have access to C-Tools."
      refute_text "Place a hold"
    end

    test "creating a hold on an item that requires approval and approval is granted" do
      borrow_policy = create(:borrow_policy, :requires_approval)
      item = create(:item, borrow_policy:)
      create(:borrow_policy_approval, :approved, borrow_policy:, member: @member)

      visit item_path(item)

      assert_text "You can place this item on hold"

      assert_difference("Hold.count", 1) do
        click_on "Place a hold"
      end

      assert_text "Hold placed."

      hold = Hold.first!

      assert_equal item, hold.item
      assert_equal @member, hold.member
    end
  end
end
