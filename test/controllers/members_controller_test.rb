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

  test "should only load checked-out loans" do
    @ended_loan = create(:ended_loan, member: @member)
    get member_loans_url
    assert_not @controller.instance_variable_get(:@loans).include?(@ended_loan)
  end

  test "member can renew their renewable loans" do
    borrow_policy = create(:member_renewable_borrow_policy)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, member: @member, item: item)

    post member_loans_renew_url(loan)
    assert_redirected_to member_loans_url
  end

  test "member cannot renew a non-renewable loan" do
    assert_raises Pundit::NotAuthorizedError do
      post member_loans_renew_url(@loan1)
    end
  end

  test "member cannot renew another member's loan" do
    assert_raises Pundit::NotAuthorizedError do
      post member_loans_renew_url(@loan2)
    end
  end
end
