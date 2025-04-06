require "application_system_test_case"

class HoldsTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "pending member can reserve items" do
    @member = create(:member, :with_user)
    @item = create(:item)
    create_open_day_for_loan(@item)

    visit admin_member_holds_url(@member)

    assert_content "need to be verified"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
    end
  end

  test "member without membership can reserve items" do
    @member = create(:verified_member)
    @item = create(:item)
    create_open_day_for_loan(@item)

    visit admin_member_url(@member)

    assert_content "needs to start a membership"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
    end
  end

  test "places item on hold" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    create_open_day_for_loan(@item)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
      click_on "Cancel"
    end

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "places a checked out item on hold" do
    @loan = create(:loan)
    @item = @loan.item
    @member = create(:verified_member_with_membership)
    create_open_day_for_loan(@item)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Hold"

    within "#current-holds" do
      assert_text @item.name
      click_on "Cancel"
    end

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "shows if an item is on hold during checkout" do
    @item = create(:item)
    @hold = create(:hold, item: @item, creator: @user)
    @member = create(:verified_member_with_membership)
    create_open_day_for_loan(@item)

    visit admin_member_holds_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      click_on "on hold by 1 person"
    end

    assert_text @member.preferred_name
  end

  test "can reserve an item for member with overdue item" do
    @item = create(:item)
    @overdue_item = create(:item)
    @member = create(:verified_member_with_membership)
    create_open_day_for_loan(@item)

    create(:loan, item: @overdue_item, member: @member, due_at: 1.week.ago)

    visit admin_member_holds_url(@member)

    within ".member-lookup-items" do
      fill_in :admin_lookup_item_number, with: @item.number
      click_on "Lookup"
      assert_button "Hold", disabled: false
    end
  end

  test "lends all holds" do
    @member = create(:verified_member_with_membership)
    @item = create(:item)
    @hold = create(:hold, member: @member, item: @item, creator: @user)
    create_open_day_for_loan(@item)

    visit admin_member_holds_url(@member)

    within "#current-holds" do
      assert_text @item.name
    end

    click_on "Lend All Holds"

    within "#current-loans" do
      assert_text @item.name
    end

    within(".member-tabs") do
      click_on "Holds"
    end

    refute_selector "#current-holds"
    refute_text @item.name
  end

  test "viewing an item's holds" do
    @item = create(:item)
    @active_hold = create(:hold, item: @item)
    @inactive_hold = create(:ended_hold, item: @item)

    visit admin_item_holds_path(@item)
    assert_selector("[data-hold-id='#{@active_hold.id}']")

    click_on "Ended"
    assert_selector("[data-hold-id='#{@inactive_hold.id}']")
  end

  test "reordering holds" do
    @item = create(:item)
    @holds = 4.times.map { create(:hold, item: @item) }

    visit admin_item_holds_path(@item)

    @handles = all(".drag-handle")
    assert_equal 4, @handles.size
    hold_ids = all(".item-holds-table tr[data-hold-id]").pluck("data-hold-id")

    # Make the first hold the last
    # NOTE: A short delay seems to be required for test to pass under Playwright,
    # future developers are welcome to try removing it to see if it's no longer
    # necessary
    @handles.first.drag_to @handles.last, delay: 0.25
    # Wait for the update to complete
    assert_no_selector "div[data-controller='hold-order'][aria-busy='true']"

    # make sure it worked
    reordered_hold_ids = all(".item-holds-table tr[data-hold-id]").pluck("data-hold-id")
    expected_hold_ids = hold_ids[1..] + [hold_ids[0]]
    assert_equal expected_hold_ids, reordered_hold_ids

    # reload the page and make sure it was persisted
    visit admin_item_holds_path(@item)
    reloaded_hold_ids = all(".item-holds-table tr[data-hold-id]").pluck("data-hold-id")
    assert_equal expected_hold_ids, reloaded_hold_ids
  end

  test "ending a specific hold on an item" do
    # use factory bot to create a few started holds
    @holds = create_list(:started_hold, 3)
    @a_hold = @holds.first
    @item = @a_hold.item

    # visit the admin item holds page
    visit admin_item_holds_path(@item)

    # end the hold we're testing and verify the hold element vanishes
    within "[data-hold-id='#{@a_hold.id}']" do
      accept_confirm { click_on "Remove Hold" }
      assert_no_selector("[data-hold-id='#{@a_hold.id}']")
    end
  end
end
