# frozen_string_literal: true

require "test_helper"

module Admin
  class UIControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @borrow_policy = create(:default_borrow_policy)
      @user = create(:admin_user)
      sign_in @user
    end

    test "autocompletes item names" do
      ["impact hammer", "Impact hammer", "Impact wrench", "hammer drill"].each do |name|
        Item.create!(name:, borrow_policy: @borrow_policy)
      end

      get admin_ui_names_url(q: "im")

      assert_response :success
      assert_equal ["Impact hammer", "Impact wrench"], JSON.parse(response.body)
    end

    test "autocompletes item brands" do
      ["Dewalt", "Delta", "ACDelco", "Dremel"].each do |brand|
        Item.create!(name: "Tool name", brand:, borrow_policy: @borrow_policy)
      end

      get admin_ui_brands_url(q: "de")

      assert_response :success
      assert_equal ["ACDelco", "Delta", "Dewalt"], JSON.parse(response.body)
    end
  end
end
