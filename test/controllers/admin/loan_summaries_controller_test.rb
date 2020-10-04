require "test_helper"

module Admin
  class LoanSummariesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      sign_in @user
    end

    test "should get index" do
      create(:loan)
      create(:ended_loan)

      get admin_loan_summaries_url
      assert_response :success
    end

    test "should get index, filtered by overdue" do
      create(:loan)
      overdue_loan = create(:loan, due_at: 1.week.ago)
      create(:ended_loan)

      get admin_loan_summaries_url(filter: "overdue")
      assert_response :success

      assert_select "table a", overdue_loan.item.name
    end
  end
end
