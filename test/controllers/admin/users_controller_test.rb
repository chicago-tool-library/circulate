require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
    end

    test "should get index" do
      create(:user)

      get admin_users_url
      assert_response :success
    end

    test "should get new" do
      get new_admin_user_url
      assert_response :success
    end

    test "should create user" do
      assert_difference("User.count") do
        post admin_users_url, params: {user: {email: "new.user@example.com", role: "staff"}}
      end

      assert_redirected_to admin_users_url

      user = User.last
      assert_equal "new.user@example.com", user.email
      assert_equal "staff", user.role
    end

    test "should show user" do
      user = create(:user)
      get admin_user_url(user)

      assert_response :success
    end

    test "should get edit" do
      user = create(:user)

      get edit_admin_user_url(user)
      assert_response :success
    end

    test "should update user" do
      user = create(:user)

      patch admin_user_url(user), params: {user: {email: "modified@example.com", role: "admin"}}
      assert_redirected_to admin_users_url

      user.reload

      assert_equal "modified@example.com", user.email
      assert_equal "admin", user.role
    end

    test "should destroy user" do
      user = create(:user)

      assert_difference("User.count", -1) do
        delete admin_user_url(user)
      end

      assert_redirected_to admin_users_url
    end
  end

  class StaffUsersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      sign_in @user
    end

    test "should get index" do
      get admin_users_url
      assert_redirected_to root_url
    end
  end
end
