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

  test "updating a organization successfully" do
    organization = create(:organization)

    visit admin_organization_path(organization)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    fill_in "Website", with: @attributes[:website]

    assert_difference("Organization.count", 0) do
      click_on "Update Organization"
      assert_text "Organization was successfully updated"
    end

    organization.reload

    assert_equal admin_organization_path(organization), current_path
    assert_equal @attributes[:name], organization.name
    assert_equal @attributes[:website], organization.website
  end

  test "updating a organization with errors" do
    organization = create(:organization)
    original_name = organization.name
    visit admin_organization_path(organization)
    click_on "Edit"

    fill_in "Name", with: ""
    fill_in "Website", with: @attributes[:website]

    assert_difference("Organization.count", 0) do
      click_on "Update Organization"
      assert_text "can't be blank"
    end

    organization.reload

    assert_equal original_name, organization.name
  end

  test "destroying a organization" do
    organization = create(:organization)
    visit edit_admin_organization_path(organization)

    assert_difference("Organization.count", -1) do
      find("summary", text: "Destroy this organization?").click
      accept_confirm do
        click_on("Destroy Organization")
      end
      assert_text "Organization was successfully destroyed."
    end
  end
end
