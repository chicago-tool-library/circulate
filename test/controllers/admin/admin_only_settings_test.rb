require "test_helper"

module Admin
  # These settings pages are hidden from Staff in the sidebar, and Staff
  # can't reach them by URL either.
  class AdminOnlySettingsTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @document = create(:agreement_document)
    end

    test "staff are turned away from the admin-only settings pages" do
      sign_in create(:staff_user)

      [
        admin_documents_url,
        admin_document_url(@document),
        edit_admin_document_url(@document),
        admin_manage_features_url,
        admin_settings_email_settings_url,
        edit_admin_settings_email_settings_url,
        preview_admin_settings_email_settings_url,
        admin_settings_exports_url
      ].each do |url|
        get url
        assert_redirected_to root_url, "expected staff to be redirected from #{url}"
      end
    end

    test "staff can't download the member or item exports" do
      sign_in create(:staff_user)

      post members_admin_settings_exports_url
      assert_redirected_to root_url

      post items_admin_settings_exports_url
      assert_redirected_to root_url
    end

    test "staff can't change documents, features or email settings" do
      sign_in create(:staff_user)

      patch admin_document_url(@document), params: {document: {name: "Changed"}}
      assert_redirected_to root_url
      assert_not_equal "Changed", @document.reload.name

      patch admin_manage_feature_url(libraries(:chicago_tool_library)), params: {library: {allow_members: "0"}}
      assert_redirected_to root_url

      patch admin_settings_email_settings_url, params: {library: {email_banner1: "Changed"}}
      assert_redirected_to root_url
    end

    test "admins can open the admin-only settings pages" do
      sign_in create(:admin_user)

      [
        admin_documents_url,
        admin_manage_features_url,
        admin_settings_email_settings_url,
        admin_settings_exports_url
      ].each do |url|
        get url
        assert_response :success, "expected admin to reach #{url}"
      end
    end
  end
end
