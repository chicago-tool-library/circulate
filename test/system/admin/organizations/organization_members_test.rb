require "application_system_test_case"

class AdminOrganizationMembersTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @organization = create(:organization)
    @attributes = attributes_for(:organization_member).slice(:full_name)
    @user_attributes = attributes_for(:user).slice(:email)
  end

  test "visiting the index" do
    organization_members = create_list(:organization_member, 3, :admin, organization: @organization)

    visit admin_organization_url(@organization)

    organization_members.each do |organization_member|
      assert_text organization_member.full_name
      assert_text organization_member.user_id
      assert_text organization_member.role.capitalize
    end
  end

  test "viewing an organization member" do
    organization_member = create(:organization_member, :admin, organization: @organization)

    visit admin_organization_url(@organization)

    click_on organization_member.full_name

    assert_text organization_member.user.email
    assert_text organization_member.full_name
    assert_text @organization.name
    assert_text organization_member.role.capitalize
    assert_current_path admin_organization_member_path(organization_member)
  end

  test "creating an organization member successfully (no existing user)" do
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]
    fill_in "Email", with: @user_attributes[:email]

    assert_difference -> { User.count } => 1, -> { OrganizationMember.count } => 1 do
      click_on "Create Organization member"
      assert_text "Organization Member was successfully created"
    end

    organization_member = OrganizationMember.last!

    assert_equal @attributes[:full_name], organization_member.full_name
    assert_equal @user_attributes[:email], organization_member.user.email
  end

  test "creating an organization member successfully (with an existing user)" do
    existing_user = create(:user)
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]
    fill_in "Email", with: existing_user.email
    select "Admin", from: "Role"

    assert_difference -> { User.count } => 0, -> { OrganizationMember.count } => 1 do
      click_on "Create Organization member"
      assert_text "Organization Member was successfully created"
    end

    organization_member = OrganizationMember.last!

    assert_equal @attributes[:full_name], organization_member.full_name
    assert_equal "admin", organization_member.role
    assert_equal existing_user, organization_member.user
  end

  test "creating an organization member with errors on the organization member" do
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: ""
    fill_in "Email", with: @user_attributes[:email]
    select "Admin", from: "Role"

    assert_difference -> { User.count } => 0, -> { OrganizationMember.count } => 0 do
      click_on "Create Organization member"
      assert_text "can't be blank"
    end
  end

  test "creating an organization member with errors on the user" do
    visit admin_organization_url(@organization)
    click_on "New Organization Member"

    fill_in "Full name", with: @attributes[:full_name]
    fill_in "Email", with: ""
    select "Admin", from: "Role"

    assert_difference -> { User.count } => 0, -> { OrganizationMember.count } => 0 do
      click_on "Create Organization member"
      assert_text "can't be blank"
    end
  end

  test "updating an organization member successfully" do
    organization_member = create(:organization_member, :admin, organization: @organization)

    visit admin_organization_member_path(organization_member)
    click_on "Edit"

    fill_in "Full name", with: @attributes[:full_name]
    select "Member", from: "Role"

    assert_difference("OrganizationMember.count", 0) do
      click_on "Update Organization member"
      assert_text "Organization Member was successfully updated"
    end

    organization_member.reload

    assert_equal admin_organization_member_path(organization_member), current_path
    assert_equal @attributes[:full_name], organization_member.full_name
    assert_equal "member", organization_member.role
  end

  test "updating a organization with errors" do
    organization_member = create(:organization_member, :admin, organization: @organization)
    original_full_name = organization_member.full_name
    visit admin_organization_member_path(organization_member)
    click_on "Edit"

    fill_in "Full name", with: ""
    select "Member", from: "Role"

    assert_difference("OrganizationMember.count", 0) do
      click_on "Update Organization member"
      assert_text "can't be blank"
    end

    organization_member.reload

    assert_equal original_full_name, organization_member.full_name
    assert_equal "admin", organization_member.role
  end

  test "destroying an organization member" do
    organization_member = create(:organization_member)
    visit edit_admin_organization_member_path(organization_member)

    assert_difference("OrganizationMember.count", -1) do
      find("summary", text: "Destroy this organization member?").click
      accept_confirm do
        click_on("Destroy Organization Member")
      end
      assert_text "Organization Member was successfully destroyed."
    end
  end
end
