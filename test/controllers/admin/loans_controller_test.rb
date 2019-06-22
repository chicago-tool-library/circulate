require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @loan = loans(:active)
    @user = users(:admin)
    @item = items(:available)
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
    assert_difference("Loan.count") do
      post admin_loans_url, params: {loan: {item_number: @item.number, member_id: @loan.member_id}}
    end

    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")
  end

  test "should show loan" do
    get admin_loan_url(@loan)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_loan_url(@loan)
    assert_response :success
  end

  test "should update loan" do
    patch admin_loan_url(@loan), params: {loan: {ended: "1"}}
    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")

    @loan.reload
    refute flash[:checkout_error]
    assert @loan.ended_at.present?
  end

  test "should update loan and mark as not ended" do
    loan = loans(:ended)
    patch admin_loan_url(loan), params: {loan: {ended: "0"}}
    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")

    loan.reload
    assert loan.ended_at.nil?
  end

  test "should destroy loan" do
    assert_difference("Loan.count", -1) do
      delete admin_loan_url(@loan)
    end

    assert_redirected_to admin_loans_url
  end
end
