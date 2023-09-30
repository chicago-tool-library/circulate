# frozen_string_literal: true

require "test_helper"

module Admin
  module Reports
    class MoneyControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "should get index" do
        create(:membership_adjustment)
        create(:cash_payment_adjustment)
        create(:square_payment_adjustment)

        get admin_reports_money_url
        assert_response :success
      end
    end
  end
end
