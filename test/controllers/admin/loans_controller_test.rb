require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = create(:item)
    @user = create(:user)
    sign_in @user
  end

  test "should get index" do
    get admin_loans_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_loan_url
    assert_response :success
  end

  test "should create loan" do
    member = create(:member)
    assert_difference("Loan.count") do
      post admin_loans_url, params: {loan: {item_number: @item.number, member_id: member.id}}
    end

    assert_redirected_to admin_member_url(member, anchor: "checkout")
  end

  test "should show loan" do
    @loan = create(:loan, item: @item)
    get admin_loan_url(@loan)
    assert_response :success
  end

  test "should get edit" do
    @loan = create(:loan, item: @item)
    get edit_admin_loan_url(@loan)
    assert_response :success
  end

  test "should update loan" do
    @loan = create(:loan, item: @item)
    patch admin_loan_url(@loan), params: {loan: {ended: "1"}}
    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")

    @loan.reload
    refute flash[:checkout_error]
    assert @loan.ended_at.present?
  end

  test "should update loan and mark as not ended" do
    ended_loan = create(:ended_loan)
    patch admin_loan_url(ended_loan), params: {loan: {ended: "0"}}
    assert_redirected_to admin_member_url(ended_loan.member, anchor: "checkout")

    ended_loan.reload
    assert ended_loan.ended_at.nil?
  end

  test "should destroy loan" do
    @loan = create(:loan, item: @item)
    assert_difference("Loan.count", -1) do
      delete admin_loan_url(@loan)
    end

    assert_redirected_to admin_loans_url
  end
end
