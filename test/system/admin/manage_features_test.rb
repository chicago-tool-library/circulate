require "application_system_test_case"

class ManageFeaturesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "do not update allowing member signups for library" do
    audited_as_admin do
      @current_library = create(:library)
    end

    visit admin_manage_features_url

    click_on "Update Library"

    assert_text "You didn't make any changes"
  end

  test "updates allowing member signups for library" do
    audited_as_admin do
      @current_library = create(:library)
    end

    visit admin_manage_features_url

    find(".form-checkbox").click
    click_on "Update Library"

    assert_text "You have successfully updated the library"
  end
end
