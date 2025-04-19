require "test_helper"

module Admin
  class BulkRenewalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = create(:admin_user)
      sign_in @admin
    end

    test "should renew all renewable loans" do
      @member = create(:verified_member)
      @loans = create_list(:loan, 5, member: @member)

      # NOTE(chaserx): ensure that at least on of the items on loan is not renewable.
      @loans[2].item.borrow_policy.update(renewal_limit: 0)

      assert_difference("Loan.count", 4) do
        put admin_bulk_renewal_url(@member)
      end

      assert_redirected_to admin_member_url(@member)

      @first_renewal = @loans.first.renewals.first
      assert_equal 1, @first_renewal.renewal_count

      @last_renewal = @loans.last.renewals.first
      assert_equal 1, @last_renewal.renewal_count
    end
  end
end
