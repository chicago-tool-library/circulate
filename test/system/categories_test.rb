require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "visiting the index" do
    visit admin_categories_url
    assert_selector "h1", text: "Categories"
  end

  test "creating a Category" do
    visit admin_categories_url
    click_on "New Category"

    fill_in "Name", with: "Category Name"
    click_on "Create Category"

    assert_text "Category was successfully created"
    assert_text "Category Name"
  end

  test "updating a Category" do
    visit admin_categories_url
    click_on "Edit", match: :first

    fill_in "Name", with: "Modified Name"
    click_on "Update Category"

    assert_text "Category was successfully updated"
    assert_text "Modified Name"
  end

  test "destroying a Category" do
    @categoroy = create(:category)
    visit admin_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Category was successfully destroyed"
    refute_text @category.name
  end
end
