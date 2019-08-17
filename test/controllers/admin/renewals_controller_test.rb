require "test_helper"

class RenewalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should renew loan" do
    @loan = create(:loan)

    #    assert_difference("Loan.count") do
    post admin_loan_renewals_url(@loan)
    #    end

    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")

    @loan.reload

    assert @loan.ended_at
    assert_equal 1, @loan.renewals.count

    @renewal = @loan.renewals.first
    assert_equal 1, @renewal.renewal_count

    assert_equal @loan.item_id, @renewal.item_id
    assert_equal @loan.member_id, @renewal.member_id
    assert_equal @loan.ended_at, @renewal.created_at
    refute @renewal.ended_at
  end
end
