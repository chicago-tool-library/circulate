require "test_helper"

module SuperAdmin
  class LibrariesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @library = create(:library)

      @user = users(:super_admin)
      sign_in @user
    end

    test "should get index" do
      get super_admin_libraries_url
      assert_response :success
    end

    test "should get new" do
      get new_super_admin_library_url
      assert_response :success
    end

    test "should create library" do
      assert_difference("Library.count") do
        post super_admin_libraries_url, params: {library: {name: "Just Books, No Cookies Library", hostname: "books.example.com"}}
      end

      assert_redirected_to super_admin_libraries_url
    end

    test "should show item" do
      get super_admin_library_url(@library)
      assert_response :success
    end

    test "should get edit" do
      get edit_super_admin_library_url(@library)
      assert_response :success
    end

    test "should update item" do
      patch super_admin_library_url(@library), params: {library: {name: "Bronze Tools Library", hostname: "bronze.example.com"}}
      assert_redirected_to super_admin_library_url(@library)
    end

    test "should destroy item" do
      assert_difference("Library.count", -1) do
        delete super_admin_library_url(@library)
      end

      assert_redirected_to super_admin_libraries_url
    end
  end
end
