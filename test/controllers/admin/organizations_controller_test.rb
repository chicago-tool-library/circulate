require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
  end

  test "should get index" do
    get admin_organizations_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_organization_url
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post admin_organizations_url, params: {organization: {name: @organization.name}}
    end

    assert_redirected_to admin_organization_url(Organization.last)
  end

  test "should show organization" do
    get admin_organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch admin_organization_url(@organization), params: {organization: {name: @organization.name}}
    assert_redirected_to admin_organization_url(@organization)
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete admin_organization_url(@organization)
    end

    assert_redirected_to admin_organizations_url
  end
end
