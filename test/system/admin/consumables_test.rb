require "application_system_test_case"

class ConsumablesTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "checks out consumable item to member and then undoes the loan" do
    @item = create(:consumable_item)
    @member = create(:verified_member_with_membership)

    visit admin_member_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Lend"

    within "#returned-loans" do
      assert_text @item.name
    end

    visit admin_item_url(@item)

    within ".item-stats" do
      assert_text "9 in stock"
    end

    visit admin_member_url(@member)

    within "#returned-loans" do
      assert_text @item.name
      click_on "Undo loan"
    end

    refute_selector "#current-loans"
    refute_text @item.name

    visit admin_item_url(@item)

    within ".item-stats" do
      assert_text "10 in stock"
    end
  end

  test "checks out consumable item from appointment page" do
    @item = create(:consumable_item)
    @member = create(:verified_member_with_membership)
    hold = create(:hold, item: @item, member: @member)
    appointment = create(:appointment, holds: [hold], member: hold.member)

    visit admin_appointment_path(appointment)

    click_on "Check-out"

    visit admin_member_url(@member)

    within "#returned-loans" do
      assert_text @item.name
    end

    visit admin_item_url(@item)

    within ".item-stats" do
      assert_text "9 in stock"
    end
  end

  test "checks out the last of a consumable item from appointment page" do
    @item = create(:consumable_item, quantity: 1)
    @member = create(:verified_member_with_membership)
    hold = create(:hold, item: @item, member: @member)
    appointment = create(:appointment, holds: [hold], member: hold.member)

    visit admin_appointment_path(appointment)

    click_on "Check-out"

    visit admin_member_url(@member)

    within "#returned-loans" do
      assert_text @item.name
    end

    visit admin_item_url(@item)

    within ".item-stats" do
      assert_text "0 in stock"
    end
  end
end
