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

    test "lists renewal requests" do
      get admin_renewal_requests_url
      assert_response :success
    end

    test "renews a loan on approval" do
      put admin_renewal_request_path(@renewal_request), params: {
        renewal_request: {
          status: :approved
        }
      }
      assert_response :redirect

      assert @renewal_request.reload.approved?
      refute @renewal_request.loan.checked_out?
    end

    test "rejects a renewal" do
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

class RenewalRequestsControllerAdditionalTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Lending

  setup do
    @user = create(:admin_user)
    sign_in @user
  end

  test "renews an already renewed loan on approval" do
    item = create(:item)
    loan = create(:loan, item: item)
    renewed_loan = renew_loan(loan)

    renewal_request = create(:renewal_request, loan: renewed_loan)

    put admin_renewal_request_path(renewal_request), params: {
      renewal_request: {
        status: :approved
      }
    }
    assert_response :redirect

    assert renewal_request.reload.approved?
    refute renewal_request.loan.checked_out?
  end
end
