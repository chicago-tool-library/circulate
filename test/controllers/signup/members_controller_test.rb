require "test_helper"

module Signup
  class MembersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
    end

    test "submits the member form" do
      travel_to Time.current do
        assert_difference("Member.count", 1) do
          post signup_members_url, params: {
            member_signup_form: attributes_for(:member, password: "password", password_confirmation: "password")
          }
        end

        assert_redirected_to signup_agreement_url
        assert_equal Time.current + Signup::BaseController::SIGNUP_TIMEOUT, session[:timeout]
      end
    end
  end
end
