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

  test "should create loan" do
    member = create(:member)
    assert_difference("Loan.count") do
      post admin_loans_url, params: {loan: {item_id: @item.id, member_id: member.id}}
    end

    assert_redirected_to admin_member_url(member, anchor: "checkout")
  end

  test "should update loan" do
    @loan = create(:loan, item: @item)
    patch admin_loan_url(@loan), params: {loan: {ended: "1"}}
    assert_redirected_to admin_member_url(@loan.member, anchor: "checkout")

    @loan.reload
    refute flash[:checkout_error]
    assert @loan.ended_at.present?
  end

  test "should update loan for an overdue item" do
    @loan = create(:loan, item: @item, due_at: 8.days.ago)
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
end
