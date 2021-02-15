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
  end
end
