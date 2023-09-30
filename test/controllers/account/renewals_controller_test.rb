# frozen_string_literal: true

require "test_helper"

module Account
  class RenewalsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      @loan1 = create(:loan, member: @member)
      @loan2 = create(:loan)

      sign_in @user
    end

    test "member can renew their renewable loans" do
      borrow_policy = create(:member_renewable_borrow_policy)
      item = create(:item, borrow_policy:)
      loan = create(:loan, member: @member, item:)

      post account_renewals_url(loan_id: loan)
      assert_redirected_to account_home_url
    end

    test "member cannot renew a non-renewable loan" do
      assert_raises Pundit::NotAuthorizedError do
        post account_renewals_url(loan_id: @loan1)
      end
    end

    test "member cannot renew another member's loan" do
      assert_raises Pundit::NotAuthorizedError do
        post account_renewals_url(loan_id: @loan2)
      end
    end
  end
end
