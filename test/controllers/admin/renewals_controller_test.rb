# frozen_string_literal: true

require "test_helper"

module Admin
  class RenewalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include Lending

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "should renew loan" do
      @loan = create(:loan)

      assert_difference("Loan.count") do
        post admin_renewals_url(loan_id: @loan)
      end

      assert_redirected_to admin_member_url(@loan.member, anchor: "loan_#{Loan.last.id}")

      @loan.reload

      assert @loan.ended_at
      assert_equal 1, @loan.renewals.count

      @renewal = @loan.renewals.first
      assert_equal 1, @renewal.renewal_count

      assert_equal @loan.item_id, @renewal.item_id
      assert_equal @loan.member_id, @renewal.member_id
      assert_equal @loan.ended_at, @renewal.created_at
      assert_not @renewal.ended_at
    end

    test "should delete renewal" do
      @loan = create(:loan)
      @renewal = renew_loan(@loan)

      assert_difference("Loan.count", -1) do
        delete admin_renewal_url(@renewal)
      end

      assert_redirected_to admin_member_url(@loan.member, anchor: "loan_#{@loan.id}")

      @loan.reload

      assert_not @loan.ended_at
      assert_equal 0, @loan.renewals.count
    end
  end
end
