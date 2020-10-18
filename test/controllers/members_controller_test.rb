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

  test "member can renew their renewable loans" do
    borrow_policy = create(:member_renewable_borrow_policy)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, member: @member, item: item)

    post member_loans_renew_url(loan)
    assert_redirected_to account_home_url
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
