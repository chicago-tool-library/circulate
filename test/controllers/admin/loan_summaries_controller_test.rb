require "test_helper"

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
end
