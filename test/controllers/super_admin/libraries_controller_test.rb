require "test_helper"

module SuperAdmin
  class LibrariesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @library = create(:library)

      @user = create(:super_admin_user)
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
        post super_admin_libraries_url, params: {library: attributes_for(:library)}
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

  class SuperAdminLibrariesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_access_denied(&block)
      block.call

      assert_redirected_to items_url
      assert_equal "You do not have access to that page.", flash[:warning]
    end

    test "should require super admin role" do
      sign_in create(:admin_user)
      library = create(:library)

      assert_access_denied { get super_admin_libraries_url }
      assert_access_denied { get new_super_admin_library_url }
      assert_access_denied { post super_admin_libraries_url, params: {library: {name: "Library", hostname: "library.example.com"}} }
      assert_access_denied { get super_admin_library_url(library) }
      assert_access_denied { get edit_super_admin_library_url(library) }
      assert_access_denied { patch super_admin_library_url(library), params: {library: {name: "Library", hostname: "library.example.com"}} }
      assert_access_denied { delete super_admin_library_url(library) }
    end
  end
end
