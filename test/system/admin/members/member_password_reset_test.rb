require "application_system_test_case"

class Admin::MemberPasswordResetTest < ApplicationSystemTestCase
  def member
    @member ||= create(:verified_member, :with_user)
  end

  setup do
    @generated_password = User.generate_temporary_password

    sign_in_as_admin
    visit admin_member_url(member)
  end

  test "an admin can reset a member's password a specific value" do
    within(".tab-action") do
      click_on "More tabs"
      click_on "Reset Password"
    end

    assert_current_path edit_admin_member_passwords_path(member)

    new_password = "new-password"

    fill_in "user_password", with: new_password

    accept_confirm { click_on "Reset Password" }

    assert_text "Successfully reset member's password"

    assert member.user.reload.valid_password?(new_password), "Failed to update password"
  end

  test "an admin can reset a member's password to a generated value" do
    User.stub(:generate_temporary_password, @generated_password) do
      within(".tab-action") do
        click_on "More tabs"
        click_on "Reset Password"
      end

      assert_current_path edit_admin_member_passwords_path(member)

      assert_selector "input[value='#{@generated_password}']"
    end

    accept_confirm { click_on "Reset Password" }

    assert_text "Successfully reset member's password"

    assert member.user.reload.valid_password?(@generated_password), "Failed to update password"
  end

  test "an admin sees errors when trying to set a user's password to something invalid" do
    within(".tab-action") do
      click_on "More tabs"
      click_on "Reset Password"
    end

    fill_in "user_password", with: ""

    accept_confirm { click_on "Reset Password" }

    assert_text "Please correct the errors below!"
    assert_text "can't be blank"
  end

  test "resetting a member's password sends them an email" do
    User.stub(:generate_temporary_password, @generated_password) do
      within(".tab-action") do
        click_on "More tabs"
        click_on "Reset Password"
      end

      assert_current_path edit_admin_member_passwords_path(member)

      assert_selector "input[value='#{@generated_password}']"
    end

    accept_confirm { click_on "Reset Password" }

    assert_text "Successfully reset member's password"

    assert_delivered_email(to: member.email) do |html, text, _attachments, subject|
      assert_equal subject, "Your password has been reset by a librarian"

      assert_includes html, @generated_password
      assert_includes text, @generated_password
    end
  end
end
