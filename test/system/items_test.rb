require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "creating an item" do
    @item = build(:item)

    visit admin_items_url
    click_on "New Item"

    fill_in "Name", with: @item.name
    find("summary", text: "Description").click
    fill_in_rich_text_area "item_description", with: @item.description
    fill_in "Size", with: @item.size
    fill_in "Strength", with: @item.strength
    fill_in "Brand", with: @item.brand
    fill_in "Model", with: @item.model
    fill_in "Serial", with: @item.serial
    click_on "Create Item"

    assert_text "Item was successfully created"
  end

  test "updating an item" do
    audited_as_admin do
      @item = create(:item)
    end

    visit admin_item_url(@item)
    click_on "Edit"

    fill_in "Name", with: @item.name
    fill_in "Brand", with: @item.brand
    fill_in_rich_text_area "item_description", with: @item.description
    fill_in "Model", with: @item.model
    fill_in "Serial", with: @item.serial
    fill_in "Size", with: @item.size
    click_on "Update Item"

    assert_text "Item was successfully updated"
  end

  test "destroying an item" do
    audited_as_admin do
      @item = create(:item)
    end

    visit edit_admin_item_url(@item)
    page.accept_confirm do
      click_on "Destroy Item"
    end

    assert_text "Item was successfully destroyed"
  end
end
