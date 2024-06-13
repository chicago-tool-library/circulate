require "application_system_test_case"

class LibrariesTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, role: "super_admin")
    login_as(@user, scope: :user)
  end

  test "listing libraries" do
    @chicago = create(:library, name: "Chicago Tool Library")
    @denver = create(:library, name: "Denver Tool Library")

    visit super_admin_libraries_path

    assert_text @chicago.name
    assert_text @denver.name
  end

  test "viewing a library" do
    @library = Library.first!

    visit super_admin_library_path(@library)

    assert_text @library.name
    assert_text @library.city
    assert_text @library.email
    assert_text @library.hostname
    assert_text @library.maximum_reservation_length
    assert_text @library.minimum_reservation_start_distance
    assert_text @library.maximum_reservation_start_distance
  end

  test "creating a library" do
    attributes = attributes_for(:library)

    visit super_admin_libraries_path
    click_on "New Library"

    fill_in "Name", with: attributes[:name]
    fill_in "Hostname", with: attributes[:hostname]
    fill_in "City", with: attributes[:city]
    fill_in "Email", with: attributes[:email]
    fill_in "Maximum reservation length", with: attributes[:maximum_reservation_length]
    fill_in "Minimum reservation start distance", with: attributes[:minimum_reservation_start_distance]
    fill_in "Maximum reservation start distance", with: attributes[:maximum_reservation_start_distance]

    assert_difference("Library.count", 1) do
      click_on "Create Library"
      assert_text "Library successfully created."
    end
  end

  test "updating a library" do
    attributes = attributes_for(:library)
    @library = Library.first!

    visit edit_super_admin_library_path(@library)

    fill_in "Name", with: attributes[:name]
    fill_in "Hostname", with: attributes[:hostname]
    fill_in "City", with: attributes[:city]
    fill_in "Email", with: attributes[:email]
    fill_in "Maximum reservation length", with: attributes[:maximum_reservation_length]
    fill_in "Minimum reservation start distance", with: attributes[:minimum_reservation_start_distance]
    fill_in "Maximum reservation start distance", with: attributes[:maximum_reservation_start_distance]

    assert_difference("Library.count", 0) do
      click_on "Update Library"
      assert_text "Library successfully updated."
    end
  end
end
