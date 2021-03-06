require "test_helper"

module Admin
  class RenewalRequestsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @item = create(:item)
      @loan = create(:loan, item: @item)
      @renewal_request = create(:renewal_request, loan: @loan)
      @user = create(:admin_user)
      sign_in @user
    end

    test "should get index" do
      get admin_renewal_requests_url
      assert_response :success
    end

    test "should renew a loan on approval" do
      put admin_renewal_request_path(@renewal_request), params: {
        renewal_request: {
          status: :approved
        }
      }
      assert_response :redirect

      assert @renewal_request.reload.approved?
      refute @renewal_request.loan.checked_out?
    end

    test "should reject a renewal" do
      put admin_renewal_request_path(@renewal_request), params: {
        renewal_request: {
          status: :rejected
        }
      }
      assert_response :redirect

      assert @renewal_request.reload.rejected?
    end
  end
end
