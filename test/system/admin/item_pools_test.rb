require "application_system_test_case"

class AdminItemPoolsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = {
      brand: "new brand",
      location_area: "new location area",
      location_shelf: "new location shelf",
      model: "new model",
      name: "new name",
      other_names: "new other names",
      power_source: "solar",
      purchase_link: "new purchase link",
      size: "new size",
      strength: "new strength",
      uniquely_numbered: false,
      url: "new url"
    }
  end

  test "listing item pools" do
    item_pools = create_list(:item_pool, 3)

    visit admin_item_pools_path

    item_pools.each do |item_pool|
      assert_text item_pool.name
    end
  end

  test "viewing an item pool" do
    item_pool = create(:item_pool)

    visit admin_item_pool_path(item_pool)

    assert_text item_pool.name
  end

  test "creating an item pool successfully" do
    reservation_policies = create_list(:reservation_policy, 3)
    selected_reservation_policy = reservation_policies.sample

    visit admin_item_pools_path
    click_on "New Item Pool"

    fill_in "Brand", with: @attributes[:brand]
    fill_in "Area", with: @attributes[:location_area]
    fill_in "Shelf", with: @attributes[:location_shelf]
    fill_in "Model", with: @attributes[:model]
    fill_in "Name", with: @attributes[:name]
    fill_in "Other names", with: @attributes[:other_names]
    fill_in "Purchase link", with: @attributes[:purchase_link]
    fill_in "Size", with: @attributes[:size]
    fill_in "Strength", with: @attributes[:strength]
    fill_in "URL", with: @attributes[:url]
    select @attributes[:power_source].capitalize, from: "Power source"
    select selected_reservation_policy.name, from: "Reservation policy"
    find("label", text: "Uniquely numbered").click # uncheck "uniquely numbered" box

    assert_difference("ItemPool.count", 1) do
      click_on "Create Item pool"
      assert_text "Item pool was successfully created"
    end

    item_pool = ItemPool.last!

    assert_equal admin_item_pool_path(item_pool), current_path
    assert_equal @attributes[:brand], item_pool.brand
    assert_equal @attributes[:location_area], item_pool.location_area
    assert_equal @attributes[:location_shelf], item_pool.location_shelf
    assert_equal @attributes[:model], item_pool.model
    assert_equal @attributes[:name], item_pool.name
    assert_equal @attributes[:other_names], item_pool.other_names
    assert_equal @attributes[:purchase_link], item_pool.purchase_link
    assert_equal @attributes[:size], item_pool.size
    assert_equal @attributes[:strength], item_pool.strength
    assert_equal @attributes[:url], item_pool.url
    assert_equal @attributes[:power_source], item_pool.power_source
    assert_equal selected_reservation_policy, item_pool.reservation_policy
    refute item_pool.uniquely_numbered
  end

  test "creating an item pool with errors" do
    visit admin_item_pools_path
    click_on "New Item Pool"

    fill_in "Name", with: ""

    assert_difference("ItemPool.count", 0) do
      click_on "Create Item pool"
      assert_text "can't be blank"
    end
  end

  test "updating an item pool successfully" do
    reservation_policies = create_list(:reservation_policy, 3)
    selected_reservation_policy = reservation_policies.sample
    item_pool = create(:item_pool)
    visit admin_item_pool_path(item_pool)
    click_on "Edit"

    fill_in "Brand", with: @attributes[:brand]
    fill_in "Area", with: @attributes[:location_area]
    fill_in "Shelf", with: @attributes[:location_shelf]
    fill_in "Model", with: @attributes[:model]
    fill_in "Name", with: @attributes[:name]
    fill_in "Other names", with: @attributes[:other_names]
    fill_in "Purchase link", with: @attributes[:purchase_link]
    fill_in "Size", with: @attributes[:size]
    fill_in "Strength", with: @attributes[:strength]
    fill_in "URL", with: @attributes[:url]
    select @attributes[:power_source].capitalize, from: "Power source"
    select selected_reservation_policy.name, from: "Reservation policy"
    find("label", text: "Uniquely numbered").click # uncheck "uniquely numbered" box

    assert_difference("ItemPool.count", 0) do
      click_on "Update Item pool"
      assert_text "Item pool was successfully updated"
    end

    item_pool.reload

    assert_equal admin_item_pool_path(item_pool), current_path
    assert_equal @attributes[:brand], item_pool.brand
    assert_equal @attributes[:location_area], item_pool.location_area
    assert_equal @attributes[:location_shelf], item_pool.location_shelf
    assert_equal @attributes[:model], item_pool.model
    assert_equal @attributes[:name], item_pool.name
    assert_equal @attributes[:other_names], item_pool.other_names
    assert_equal @attributes[:purchase_link], item_pool.purchase_link
    assert_equal @attributes[:size], item_pool.size
    assert_equal @attributes[:strength], item_pool.strength
    assert_equal @attributes[:url], item_pool.url
    assert_equal @attributes[:power_source], item_pool.power_source
    assert_equal selected_reservation_policy, item_pool.reservation_policy
    refute item_pool.uniquely_numbered
  end

  test "updating an item pool with errors" do
    reservation_policies = create_list(:reservation_policy, 3)
    selected_reservation_policy = reservation_policies.sample
    item_pool = create(:item_pool)
    visit admin_item_pool_path(item_pool)
    click_on "Edit"

    fill_in "Name", with: ""

    assert_difference("ReservationPolicy.count", 0) do
      click_on "Update Item pool"
      assert_text "can't be blank"
    end

    item_pool.reload

    refute_equal admin_item_pool_path(item_pool), current_path
    refute_equal @attributes[:brand], item_pool.brand
    refute_equal @attributes[:location_area], item_pool.location_area
    refute_equal @attributes[:location_shelf], item_pool.location_shelf
    refute_equal @attributes[:model], item_pool.model
    refute_equal @attributes[:name], item_pool.name
    refute_equal @attributes[:other_names], item_pool.other_names
    refute_equal @attributes[:purchase_link], item_pool.purchase_link
    refute_equal @attributes[:size], item_pool.size
    refute_equal @attributes[:strength], item_pool.strength
    refute_equal @attributes[:url], item_pool.url
    refute_equal @attributes[:power_source], item_pool.power_source
    refute_equal selected_reservation_policy, item_pool.reservation_policy
    assert item_pool.uniquely_numbered
  end

  test "destroying an item pool" do
    item_pool = create(:item_pool)
    visit edit_admin_item_pool_path(item_pool)

    assert_difference("ItemPool.count", -1) do
      find("summary", text: "Destroy this item pool?").click
      scroll_to :bottom
      accept_confirm do
        find("button", text: "Destroy Item Pool").click # `click_on` struggles to find this button
      end
      assert_text "Item pool was successfully destroyed."
    end
  end
end
