# frozen_string_literal: true

require "test_helper"

module Account
  class RenewalRequestsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      @loan1 = create(:ended_loan, member: @member)
      @loan2 = create(:loan)

      sign_in @user
    end

    test "member can request renewal for loans" do
      borrow_policy = create(:default_borrow_policy)
      item = create(:item, borrow_policy:)
      loan = create(:loan, member: @member, item:)

      post account_renewal_requests_url(loan_id: loan)
      assert_redirected_to account_loans_url
    end

    test "member cannot request renewal for a non-requestable loan" do
      post account_renewal_requests_url(loan_id: @loan1)
      assert_response :forbidden
    end
  end
end
