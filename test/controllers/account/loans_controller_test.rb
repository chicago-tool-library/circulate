require "test_helper"

module Account
  class LoansControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      @loan1 = create(:ended_loan, member: @member)
      @loan2 = create(:ended_loan)

      sign_in @user
    end

    test "loads a member's past loans" do
      get account_loans_url
      assert_response :success

      assert_match @loan1.item.complete_number, response.body
      refute_match @loan2.item.complete_number, response.body
    end
  end
end
