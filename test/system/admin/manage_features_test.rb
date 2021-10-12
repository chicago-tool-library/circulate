require "application_system_test_case"

class ManageFeaturesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "do not update allowing members for library" do
    audited_as_admin do
      @current_library = create(:library)
    end

    visit admin_manage_features_url

    click_on "Update Library"

    assert_text "That's already the status!"
  end
end
