require "application_system_test_case"

module Admin
  class BorrowPolicyApprovalsNotificationsTest < ApplicationSystemTestCase
    include AdminHelper

    setup do
      sign_in_as_admin
    end

    test "the requested approvals notification message is not displayed when there aren't any requested approvals" do
      create(:borrow_policy_approval, :approved)
      create(:borrow_policy_approval, :rejected)
      create(:borrow_policy_approval, :revoked)

      # the specific path doesn't matter as long as it's in the admin interface
      visit admin_organizations_path

      refute_text "requested borrow policy approvals"
    end

    test "the requested approvals notification message is displayed when there are requested approvals" do
      create(:borrow_policy_approval, :approved)
      create(:borrow_policy_approval, :rejected)
      create(:borrow_policy_approval, :revoked)
      create_list(:borrow_policy_approval, 2, :requested)

      # the specific path doesn't matter as long as it's in the admin interface
      visit admin_organizations_path

      assert_text "requested borrow policy approvals"
    end
  end
end
