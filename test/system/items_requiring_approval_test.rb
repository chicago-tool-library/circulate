require "application_system_test_case"

class ItemsRequiringApprovalTest < ApplicationSystemTestCase
  def setup
    borrow_policy = create(:borrow_policy, :requires_approval)

    @item_requiring_approval = create(:item, borrow_policy:)
    @item_not_requiring_approval = create(:item, borrow_policy: create(:borrow_policy, requires_approval: false))
  end

  def borrow_policy_code_name(borrow_policy)
    "#{borrow_policy.code}-Tool"
  end

  test "items requiring approval are labeled in the search results" do
    visit items_path

    within("#item-#{@item_not_requiring_approval.id}") do
      refute_text borrow_policy_code_name(@item_not_requiring_approval.borrow_policy)
      refute_text borrow_policy_code_name(@item_requiring_approval.borrow_policy)
    end

    within("#item-#{@item_requiring_approval.id}") do
      assert_text borrow_policy_code_name(@item_requiring_approval.borrow_policy)
    end
  end
end
