require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    @member = create(:member, user: @user)
    @loan1 = create(:loan, member: @member)
    @loan2 = create(:loan)

    sign_in @user
  end

  test "return success response" do
    get member_loan_history_url
    assert_response :success
  end

  test "should load the member's loans" do
    get member_loans_url
    assert_equal @controller.instance_variable_get(:@loans), [@loan1]
  end

  test "only shows members loan history" do
    get member_loan_history_url
    assert_equal @controller.instance_variable_get(:@loans), [@loan1]
  end

end
