require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    create(:default_borrow_policy)
  end

  test "creating an item" do
    @item = build(:item)

    visit admin_items_url
    click_on "New Item"

    fill_in "Name", with: @item.name
    fill_in_rich_text_area "item_description", with: @item.description
    fill_in "Size", with: @item.size
    fill_in "Strength", with: @item.strength
    select "Gas", from: "Power source"
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
    select "Solar", from: "Power source"
    fill_in "Model", with: @item.model
    fill_in "Serial", with: @item.serial
    fill_in "Size", with: @item.size
    click_on "Update Item"

    assert_text "Item was successfully updated"
  end

  test "adding an image to an item and then deleting it" do
    audited_as_admin do
      @item = create(:item)
    end

    visit admin_item_url(@item)
    click_on "Edit"

    attach_file "Image", Rails.root + "test/fixtures/files/tool-image.jpg"
    click_on "Update Item"

    assert_text "Item was successfully updated"
    assert_selector ".item-image img"

    # Make sure it's only deleted when checkbox is toggled
    click_on "Edit"
    click_on "Update Item"
    assert_selector ".item-image img"

    click_on "Edit"
    # Can't use check method with spectre as its labels obscure checkboxes
    page.find("label", text: "Delete current image").click
    click_on "Update Item"

    refute_selector ".item-image img"
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
    @category1 = create(:category)
    @category2 = create(:category)
    @category3 = create(:category)

    audited_as_admin do
      @item = create(:complete_item, categories: [@category1, @category2, @category3])
    end

    visit edit_admin_item_url(@item)
    # Remove second category from item
    page.find("div[data-value='#{@category2.id}'] a.remove").click
    click_on "Update Item"

    visit admin_item_history_path(@item)
    assert_text(@category1.name)
    assert_text(@category2.name)
    assert_text(@category3.name)

    visit admin_categories_url
    # Destroy first category record
    page.accept_confirm do
      find("a[href='/admin/categories/#{@category2.id}']", text: "Destroy").click
    end
    refute_text @category2.name

    visit admin_item_history_path(@item)
    # Check than an edit event exists where item is only associated
    # with one existing category and one deleted category
    refute_text @category2.name
    assert_text(/deleted category/)
  end

  # test "importing a manual from a URL", :remote do
  #   url = "https://www.singer.com/sites/default/files/C5200%20manual.pdf"
  #   audited_as_admin do
  #     @item = create(:item)
  #   end

  #   visit admin_item_url(@item)
  #   click_on "Import Manual"

  #   fill_in "Manual URL", with: url
  #   click_on "Import Manual"

  #   assert_text "The manual was imported", wait: slow_op_wait_time
  #   assert_text "Manual: C5200-20manual.pdf"
  # end

  test "double clicking create item doesn't create multiple items" do
    @item = build(:item, name: "Repeated item name")

    visit admin_items_url
    click_on "New Item"

    fill_in "Name", with: @item.name
    fill_in_rich_text_area "item_description", with: @item.description
    fill_in "Size", with: @item.size
    fill_in "Strength", with: @item.strength
    fill_in "Brand", with: @item.brand
    fill_in "Model", with: @item.model
    fill_in "Serial", with: @item.serial
    find("button", text: "Create Item").double_click

    assert_text "Item was successfully created"
    assert_equal 1, Item.all.map(&:name).count(@item.name)
  end

  test "viewing an item's holds" do
    @item = create(:item)
    @active_hold = create(:hold, item: @item)
    @inactive_hold = create(:ended_hold, item: @item)

    visit admin_item_holds_path(@item)
    find("[data-id='#{@active_hold.id}']")

    click_on "Ended"
    find("[data-id='#{@inactive_hold.id}']")
  end

  test "reordering holds" do
    @item = create(:item)
    @holds = 4.times.map { create(:hold, item: @item) }

    visit admin_item_holds_path(@item)

    @handles = all(".drag-handle")
    assert_equal 4, @handles.size
    hold_ids = all(".item-holds-table tr[data-id]").map { |row| row["data-id"] }

    # Make the first hold the last
    @handles.first.drag_to @handles.last
    reordered_hold_ids = all(".item-holds-table tr[data-id]").map { |row| row["data-id"] }

    # make sure it worked
    expected_hold_ids = hold_ids[1..] + [hold_ids[0]]
    assert_equal expected_hold_ids, reordered_hold_ids

    # reload the page and make sure it was persisted
    visit admin_item_holds_path(@item)
    reloaded_hold_ids = all(".item-holds-table tr[data-id]").map { |row| row["data-id"] }
    assert_equal expected_hold_ids, reloaded_hold_ids
  end
end
