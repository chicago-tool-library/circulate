require "application_system_test_case"

class MultitenancyTest < ApplicationSystemTestCase
  test "login to library" do
    member = create(:member, full_name: "Reggie Brower")
    user = create(:user, member: member)

    visit user_session_url

    fill_in :user_email, with: user.email
    fill_in :user_password, with: user.password
    click_on "Login"

    within ".navbar" do
      assert_text "Logout"
    end
  end

  test "login to library without an account" do
    different_library = create(:library, hostname: "web1")

    ActsAsTenant.with_tenant(different_library) do
      @member = create(:member, full_name: "Noe Henry")
      @user = create(:user, member: @member)
    end

    visit user_session_url

    fill_in :user_email, with: @user.email
    fill_in :user_password, with: @user.password
    click_on "Login"

    within ".navbar" do
      refute_text @member.full_name
    end
    assert_button "Login"
  end

  test "view items in library" do
    user = create(:user, member: create(:member))
    item_in_library = create(:item, name: "Stud Finder")

    different_library = create(:library, hostname: "different.example.com")
    item_in_different_library = ActsAsTenant.with_tenant(different_library) { create(:item, name: "Diaper") }

    login_as user
    visit items_url

    within ".items-table" do
      assert_text item_in_library.name
      refute_text item_in_different_library.name
    end
  end

  test "super admin login" do
    super_admin = create(:super_admin_user, member: create(:member))

    visit user_session_url

    fill_in :user_email, with: super_admin.email
    fill_in :user_password, with: super_admin.password

    click_on "Login"

    assert_text "Libraries"
  end
end
