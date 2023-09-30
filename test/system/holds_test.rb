# frozen_string_literal: true

require "application_system_test_case"

class HoldsTest < ApplicationSystemTestCase
  def list_item_containing(text)
    find("li", text:)
  end

  setup do
    ActionMailer::Base.deliveries.clear
    @member = create(:verified_member_with_membership)
  end

  test "member can place a hold" do
    login_as @member.user

    @item = create(:item)

    visit item_url(@item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "You placed a hold on this item."
  end

  test "member can't place a hold on an item in maintenance" do
    login_as @member.user

    @item = create(:item, status: :maintenance)

    visit item_url(@item)

    refute_selector 'input[value="Place a hold"]'
  end

  test "member can place a hold multiple times when the borrow policy allows it" do
    login_as @member.user

    @item = create(:uncounted_item)

    visit item_url(@item)

    click_button "Place a hold"
    assert_text "You currently have 1 hold placed."

    click_button "Place a hold"
    assert_text "You currently have 2 holds placed."
  end

  test "puts checked out items on hold" do
    login_as @member.user

    @item = create(:item)
    create(:loan, item: @item)
    @popular_item = create(:item)
    create(:loan, item: @popular_item)
    create(:hold, item: @popular_item)

    visit item_url(@item)
    click_button "Place a hold"

    visit item_url(@popular_item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "You placed a hold on this item."

    visit account_holds_path
    within(list_item_containing(@item.complete_number)) { assert_text "#1 on wait list" }
    within(list_item_containing(@popular_item.complete_number)) { assert_text "#2 on wait list" }
  end

  test "member with next hold is notified when an item is returned" do
    @admin = create(:admin_user)

    @item = create(:item)
    @loan = create(:loan, item: @item)
    @hold = create(:hold, item: @item, member: @member)

    login_as @admin

    visit admin_member_url(@loan.member)

    within "#current-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector "#current-loans", wait: slow_op_wait_time

    Hold.start_waiting_holds do |hold|
      assert_equal @hold, hold
    end

    @hold.reload
    assert @hold.started?
  end

  test "holds are shown only in hold history after two weeks" do
    login_as @member.user

    @item = create(:item)

    travel_to 15.days.ago do
      create(:started_hold, member: @member, item: @item)
    end

    visit account_holds_path
    refute_text @item.complete_number
    refute_text @item.name

    visit history_account_holds_path
    assert_text @item.complete_number
    assert_text @item.name
  end
end
