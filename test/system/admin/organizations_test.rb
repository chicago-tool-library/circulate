require "application_system_test_case"

class AdminOrganizationsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = attributes_for(:organization).slice(:name, :website)
  end

  test "visiting the index" do
    organizations = create_list(:organization, 3)

    visit admin_organizations_url

    organizations.each do |organization|
      assert_text organization.name
      assert_text organization.website
    end
  end

  test "viewing an organization" do
    organization = create(:organization)

    visit admin_organizations_url

    click_on organization.name

    assert_text organization.name
    assert_text organization.website
    assert_current_path admin_organization_path(organization)
  end

  test "creating an organization successfully" do
    visit admin_organizations_url
    click_on "New Organization"

    fill_in "Name", with: @attributes[:name]
    fill_in "Website", with: @attributes[:website]

    assert_difference("Organization.count", 1) do
      click_on "Create Organization"
      assert_text "Organization was successfully created"
    end

    organization = Organization.last!

    assert_equal @attributes[:name], organization.name
    assert_equal @attributes[:website], organization.website
  end

  test "creating an organization with errors" do
    existing_organization = create(:organization)
    visit admin_organizations_url
    click_on "New Organization"

    fill_in "Name", with: existing_organization.name
    fill_in "Website", with: @attributes[:website]

    assert_difference("Organization.count", 0) do
      click_on "Create Organization"
      assert_text "has already been taken"
    end
  end
end
