require "application_system_test_case"

class UserEmailVerificationTest < ApplicationSystemTestCase
  test "unconfirmed users see a message asking them to verify their email address" do
    member = create(:member, user: create(:user, :unconfirmed))
    login_as member.user

    visit root_path

    assert_selector ".toast-warning"
    assert_text "email address has not been verified"
  end

  test "confirmed users do not see a message asking them to verify their email address" do
    member = create(:member, user: create(:user))
    login_as member.user

    visit root_path

    refute_selector ".toast-warning"
  end

  test "users that are not signed in do not see a message asking them to verify their email address" do
    visit root_path

    refute_selector ".toast-warning"
  end
end
