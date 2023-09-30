# frozen_string_literal: true

require "test_helper"

module Account
  class LoansControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      sign_in @user
    end

    test "loads a member's past loans" do
      @loan = create(:ended_loan, member: @member)
      @others_loan = create(:ended_loan)

      get history_account_loans_url
      assert_response :success

      assert_match @loan.item.complete_number, response.body
      assert_no_match @others_loan.item.complete_number, response.body
    end

    test "displays a member's current loans" do
      @loan = create(:loan, member: @member)
      @others_loan = create(:loan)
      @ended_loan = create(:ended_loan, member: @member)

      get account_loans_url
      assert_response :success

      assert_match @loan.item.complete_number, response.body
      assert_no_match @others_loan.item.complete_number, response.body
      assert_no_match @ended_loan.item.complete_number, response.body
    end
  end
end
