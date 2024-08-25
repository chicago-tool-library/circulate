require "application_system_test_case"

module Account
  class ReservationsTest < ApplicationSystemTestCase
    setup do
      @member = create(:verified_member_with_membership)
      login_as @member.user
    end

    test "members can renew all renewable loans" do
      borrow_policy = create(:member_renewable_borrow_policy)

      ignored_item = create(:item, borrow_policy:)
      create(:loan, item: ignored_item)

      renewable_item = create(:item, borrow_policy:)
      create(:loan, member: @member, item: renewable_item)

      non_renewable_item = create(:item, borrow_policy:)
      create(:loan, member: @member, item: non_renewable_item, renewal_count: borrow_policy.renewal_limit)

      visit account_loans_path

      assert_difference("Loan.count", 1) do
        click_on "Renew All"
        assert_text "Renewed"
      end

      renewed_loan = Loan.last
      assert_equal renewable_item, renewed_loan.item
    end

    test "members that lack renewable loans don't see a renew all button" do
      borrow_policy = create(:member_renewable_borrow_policy)

      non_renewable_item = create(:item, borrow_policy:)
      create(:loan, member: @member, item: non_renewable_item, renewal_count: borrow_policy.renewal_limit)

      visit account_loans_path

      refute_text "Renew All"
    end
  end
end
