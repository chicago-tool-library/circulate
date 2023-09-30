# frozen_string_literal: true

require "test_helper"

module Admin
  module Reports
    class ItemWithoutImageControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "should get index" do
        get admin_reports_items_without_image_index_url
        assert_response :success
      end
    end
  end
end
