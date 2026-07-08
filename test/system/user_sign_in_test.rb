require "application_system_test_case"

class UserSignInTest < ApplicationSystemTestCase
  test "toggling password visibility on the sign in form" do
    visit user_session_url

    fill_in :user_password, with: "super-secret"
    assert_equal "password", field_type(:user_password)

    click_on "Show password"

    assert_equal "text", field_type(:user_password)
    assert_equal "super-secret", find_field(:user_password).value

    click_on "Hide password"

    assert_equal "password", field_type(:user_password)
  end

  private

  def field_type(locator)
    find_field(locator)["type"]
  end
end
