require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    create(:default_borrow_policy)
  end

  def assert_maintenance_option_is_disabled
    assert_selector "option[value='maintenance'][disabled='disabled']"
  end

  test "creating an item" do
    @item = build(:complete_item)

    visit admin_items_url
    click_on "New Item"

    assert_maintenance_option_is_disabled
    fill_in "Name", with: @item.name
    fill_in_rich_text_area "item_description", with: @item.description
    fill_in "Size", with: @item.size
    fill_in "Strength", with: @item.strength
    select "Gas", from: "Power source"
    fill_in "Brand", with: @item.brand
    fill_in "Model", with: @item.model
    fill_in "Serial", with: @item.serial
    fill_in "Accessories", with: @item.accessories.join("\n")

    assert_difference("Item.count", 1) do
      click_on "Create Item"
      assert_text "Item was successfully created"
    end

    item = Item.last!

    assert_equal @item.name, item.name
    assert_equal @item.description.to_plain_text, item.description.to_plain_text
    assert_equal "gas", item.power_source
    assert_equal @item.size, item.size
    assert_equal @item.strength, item.strength
    assert_equal @item.brand, item.brand
    assert_equal @item.model, item.model
    assert_equal @item.serial, item.serial
    assert_equal @item.accessories, item.accessories
  end

  test "updating an item" do
    audited_as_admin do
      @item = create(:item)
    end

    attributes = attributes_for(:complete_item)

    visit admin_item_url(@item)
    click_on "Edit"

    assert_maintenance_option_is_disabled
    fill_in "Name", with: attributes[:name]
    fill_in "Brand", with: attributes[:brand]
    fill_in "Strength", with: attributes[:strength]
    select "Solar", from: "Power source"
    fill_in "Model", with: attributes[:model]
    fill_in "Serial", with: attributes[:serial]
    fill_in "Size", with: attributes[:size]
    fill_in "Accessories", with: attributes[:accessories].join("\n")

    assert_difference("Item.count", 0) do
      click_on "Update Item"
      assert_text "Item was successfully updated"
    end
    puts attributes
    @item.reload
    assert_equal attributes[:name], @item.name
    assert_equal "solar", @item.power_source
    assert_equal attributes[:size], @item.size
    assert_equal attributes[:strength], @item.strength
    assert_equal attributes[:brand], @item.brand
    assert_equal attributes[:model], @item.model
    assert_equal attributes[:serial], @item.serial
    assert_equal attributes[:accessories], @item.accessories
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
    skip "TODO rotate photo and verify that it was saved"
    audited_as_admin do
      @item = create(:item, :with_image)
    end

    visit admin_item_url(@item)

    click_on "Edit Photo"
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

    assert_selector "h1", text: @item.name

    visit admin_item_history_path(@item)
    assert_text(@category1.name)
    assert_text(@category2.name)
    assert_text(@category3.name)

    visit admin_categories_url
    # Destroy first category record
    page.accept_confirm do
      find("form[action='/admin/categories/#{@category2.id}'] button", text: "Destroy").click
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

  test "listing items" do
    @category1 = create(:category, name: "Nailguns")
    @category1_subcategory = create(:category, parent: @category1, name: "Pneumatic")
    @category2 = create(:category, name: "Drills")

    @item1 = create(:item, categories: [@category1_subcategory], name: "Nine-Inch Nailgun")
    @item2 = create(:item, categories: [@category2], name: "Boring Borer")
    @item3 = create(:item, categories: [@category2], name: "Droll Drill")

    @member = create(:verified_member_with_membership)
    @user = @member.user
    @hold = create(:hold, member: @member, item: @item3, creator: @user)

    visit admin_items_url

    assert_text "Available"
    assert_text "On Hold"
    assert_text "Active"

    within(".items-summary") do
      assert_text "Viewing all 3 items"
    end

    click_on "Drills", match: :first # there are multiple links to this category on the page
    within(".items-summary") do
      assert_text "Viewing 2 items assigned to Drills", normalize_ws: true
    end

    find("label", text: "Only show items available now").click
    within(".items-summary") do
      assert_text "Viewing 1 item assigned to Drills", normalize_ws: true
    end
  end

  test "viewing an item's status" do
    item = create(:item, :active)
    create(:overdue_loan, item:)

    visit admin_item_url(item)

    assert_text "Overdue"
    assert_text "Active"
  end
end
