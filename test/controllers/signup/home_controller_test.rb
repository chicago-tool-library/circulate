require "test_helper"

module Signup
  class HomeControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
    end

    test "renders the index page when group lending is disabled" do
      FeatureFlags.stub :group_lending_enabled?, false do
        get signup_url
        assert_response :success
      end
    end

    test "renders the index page when group lending is enabled" do
      FeatureFlags.stub :group_lending_enabled?, true do
        get signup_url
        assert_response :success
      end
    end
  end
end
