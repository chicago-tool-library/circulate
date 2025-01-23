require "application_system_test_case"

class AdminItemPoolsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = {
      name: "new name",
      other_names: "new other names",
      uniquely_numbered: false
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

    fill_in "Name", with: @attributes[:name]
    fill_in "Other names", with: @attributes[:other_names]
    select selected_reservation_policy.name, from: "Reservation policy"
    find("label", text: "Uniquely numbered").click # uncheck "uniquely numbered" box

    assert_difference("ItemPool.count", 1) do
      click_on "Create Item pool"
      assert_text "Item pool was successfully created"
    end

    item_pool = ItemPool.last!

    assert_equal admin_item_pool_path(item_pool), current_path
    assert_equal @attributes[:name], item_pool.name
    assert_equal @attributes[:other_names], item_pool.other_names
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

    fill_in "Name", with: @attributes[:name]
    fill_in "Other names", with: @attributes[:other_names]
    select selected_reservation_policy.name, from: "Reservation policy"
    find("label", text: "Uniquely numbered").click # uncheck "uniquely numbered" box

    assert_difference("ItemPool.count", 0) do
      click_on "Update Item pool"
      assert_text "Item pool was successfully updated"
    end

    item_pool.reload

    assert_equal admin_item_pool_path(item_pool), current_path
    assert_equal @attributes[:name], item_pool.name
    assert_equal @attributes[:other_names], item_pool.other_names
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
    refute_equal @attributes[:name], item_pool.name
    refute_equal @attributes[:other_names], item_pool.other_names
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
