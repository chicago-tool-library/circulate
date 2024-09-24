require "application_system_test_case"

class AdminOrganizationMembersTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @organization = create(:organization)
    @attributes = attributes_for(:organization_member).slice(:name, :website)
    @user_attributes = attributes_for(:user).slice(:email)
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

  test "creating an organization member successfully (no existing user)" do
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]
    fill_in "Email", with: @user_attributes[:email]

    assert_difference("User.count", 1) do
      assert_difference("OrganizationMember.count", 1) do
        click_on "Create Organization member"
        assert_text "Organization Member was successfully created"
      end
    end

    organization_member = OrganizationMember.last!

    assert_equal @attributes[:full_name], organization_member.full_name
    assert_equal @user_attributes[:email], organization_member.user.email
  end

  test "creating an organization member successfully (with an existing user)" do
    skip
    existing_user = create(:user)
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]
    fill_in "Email", with: existing_user.email

    assert_difference("OrganizationMember.count", 1) do
      click_on "Create Organization member"
      assert_text "Organization Member was successfully created"
    end

    organization_member = OrganizationMember.last!

    assert_equal @attributes[:full_name], organization_member.full_name
    assert_equal existing_user, organization_member.user
  end

  test "creating an organization member with errors" do
    skip
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]

    assert_difference("OrganizationMember.count", 0) do
      click_on "Create Organization member"
      assert_text "can't be blank"
    end
  end
end
