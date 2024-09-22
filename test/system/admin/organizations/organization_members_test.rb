require "application_system_test_case"

class AdminOrganizationMembersTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @organization = create(:organization)
    @attributes = attributes_for(:organization_member).slice(:name, :website)
  end

  test "visiting the index" do
    organization_members = create_list(:organization_member, 3, organization: @organization)

    visit admin_organization_url(@organization)

    organization_members.each do |organization_member|
      assert_text organization_member.full_name
      assert_text organization_member.user_id
    end
  end

  test "viewing an organization member" do
    organization_member = create(:organization_member, organization: @organization)

    visit admin_organization_url(@organization)

    click_on organization_member.full_name

    assert_text organization_member.user.email
    assert_text organization_member.full_name
    assert_text @organization.name
    assert_current_path admin_organization_member_path(organization_member)
  end
end
