require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    loan = create(:loan)
    @member = loan.member
    loan = create(:loan, member: @member)
    loan = create(:loan)
  end

  test "return success response" do
    get member_loan_history_url
    assert_response :success
  end

  test "only shows members loan history" do
    get member_loan_history_url
    assert_equal @controller.instance_variable_get(:@loans), @member.loans
  end

end
