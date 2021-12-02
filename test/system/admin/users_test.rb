require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    create(:admin_user)
    sign_in_as_admin
  end

  test "visiting the index" do
    create(:user)

    visit admin_users_url
    assert_selector "h1", text: "Users"
  end

  test "creating a user" do
    visit admin_users_url
    click_on "New User"

    fill_in "Email", with: "new.user1@example.com"
    click_on "Create User"

    assert_text "User was successfully created"
    assert_text "new.user1@example.com"
  end

  test "updating a user" do
    user = create(:user)

    visit admin_users_url

    within("#user-#{user.id}") do
      click_on "Edit"
    end

    fill_in "Email", with: "modified.user1@example.com"
    click_on "Update User"

    assert_text "User was successfully updated"
    assert_text "modified.user1@example.com"
  end

  test "destroying a user" do
    user = create(:user)

    visit admin_users_url

    page.accept_confirm do
      within("#user-#{user.id}") do
        click_on "Destroy"
      end
    end

    assert_text "User was successfully destroyed"
  end
end
