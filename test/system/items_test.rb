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

  test "adding a manual to an item and then deleting it" do
    audited_as_admin do
      @item = create(:item)
    end

    visit admin_item_url(@item)
    click_on "Edit"

    attach_file "Manual", Rails.root + "test/fixtures/files/file.pdf"
    click_on "Update Item"

    assert_text "Item was successfully updated"
    assert_text "View Manual"

    # Make sure it's only deleted when checkbox is toggled
    click_on "Edit"
    click_on "Update Item"
    assert_text "View Manual"

    click_on "Edit"
    # Can't use check method with spectre as its labels obscure checkboxes
    page.find("label", text: "Delete current manual").click
    click_on "Update Item"

    refute_text "View Manual"
  end

  test "destroying an item" do
    audited_as_admin do
      @item = create(:item)
    end

    visit edit_admin_item_url(@item)
    page.find("summary", text: "Destroy this item?").click
    page.accept_confirm do
      click_on "Destroy Item"
    end

    assert_text "Item was successfully destroyed"
  end

  test "editing an item's photo" do
    audited_as_admin do
      @item = create(:item, :with_image)
    end

    visit admin_item_url(@item)

    click_on "Edit Photo"

    # TODO rotate photo and verify that it was saved
  end

  test "accessing an item's history after deleting a category" do
    audited_as_admin do
      @item = create(:complete_item)
    end

    # Create some categories and add them to the item
    @category1 = create(:category)
    @category2 = create(:category)
    @category3 = create(:category)
    @item.categories << [@category1, @category2, @category3]

    visit edit_admin_item_url(@item)
    # Remove second category from item
    page.all("a.remove")[1].click
    click_on "Update Item"

    visit admin_categories_url
    # Destroy first category record
    page.accept_confirm do
      click_on "Destroy", match: :first
    end
    refute_text @category1.name

    visit admin_item_item_history_path(@item)
    # Check than an edit event exists where item is only associated
    # with one existing category and one deleted category
    assert_text(/Categories set to category\d, deleted category/)
  end

  test "importing a manual from a URL", :remote do
    url = "https://www.singer.com/sites/default/files/C5200%20manual.pdf"
    audited_as_admin do
      @item = create(:item)
    end

    visit admin_item_url(@item)
    click_on "Import Manual"

    fill_in "Manual URL", with: url
    click_on "Import Manual"

    assert_text "The manual was imported", wait: 10
    assert_text "Manual: C5200-20manual.pdf"
  end
end
