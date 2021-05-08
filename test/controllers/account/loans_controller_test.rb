require "test_helper"

module Account
  class HoldsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)
      @loan1 = create(:loan, member: @member)
      @loan2 = create(:loan)

      sign_in @user
    end

    test "should load the member's loans" do
      get account_loans_url
      assert_response :success

      assert_select "span", @loan1.item.complete_number.upcase
      assert_select "span", count: 0, text: @loan2.item.complete_number.upcase
    end
  end
end
