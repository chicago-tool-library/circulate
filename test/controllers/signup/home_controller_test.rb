require "test_helper"

module Signup
  class HomeControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
    end

    test "renders the index page when reservations are disabled" do
      FeatureFlags.stub :reservable_items_enabled?, false do
        get signup_url
        assert_response :success
      end
    end

    test "renders the index page when reservations are enabled" do
      FeatureFlags.stub :reservable_items_enabled?, true do
        get signup_url
        assert_response :success
      end
    end
  end
end
