# frozen_string_literal: true

require "application_system_test_case"

class CheckInCheckOutTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "pending member can't checkout items" do
    @member = create(:member)
    @item = create(:item)

    visit admin_member_url(@member)

    assert_content "need to be verified"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    assert_button "Lend", disabled: true
  end

  test "member without membership can't checkout items" do
    @member = create(:verified_member)
    @item = create(:item)

    visit admin_member_url(@member)

    assert_content "needs to start a membership"

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    assert_button "Lend", disabled: true
  end

  test "checks out items to member" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)

    visit admin_member_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end
    click_on "Lend"

    within "#current-loans" do
      assert_text @item.name
      click_on "Undo loan"
    end

    refute_selector "#current-loans"
    refute_text @item.name
  end

  test "can't check out item on loan" do
    @loan = create(:loan)
    @item = @loan.item
    @member = create(:verified_member_with_membership)

    visit admin_member_url(@member)

    fill_in :admin_lookup_item_number, with: @item.number
    click_on "Lookup"

    within ".member-lookup-items" do
      assert_text @item.complete_number
      assert_text @item.name
    end

    assert_button "Lend", disabled: true
    assert_text "currently on loan"
  end

  test "can't check out item to member with overdue item" do
    @overdue_item = create(:item)
    @member = create(:verified_member_with_membership)

    create(:loan, item: @overdue_item, member: @member, due_at: 1.week.ago)

    visit admin_member_url(@member)

    within "#current-loans" do
      assert_text @overdue_item.name
      assert_text "Overdue"
    end

    assert_text "Overdue items must be returned"

    within ".member-lookup-items" do
      refute_selector "input"
    end
  end

  test "returns loaned item" do
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    create(:loan, item: @item, member: @member)

    visit admin_member_url(@member)

    within "#current-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector "#current-loans"

    within "#returned-loans" do
      assert_text @item.name
      click_on "Undo return"
    end

    refute_selector "#returned-loans"

    within "#current-loans" do
      assert_text @item.name
    end
  end

  test "returns loaned overdue item" do
    Time.use_zone "America/Chicago" do
      @item = create(:item)
      @member = create(:verified_member_with_membership)

      create(:loan, item: @item, member: @member, due_at: 12.days.ago)

      visit admin_member_url(@member)

      within "#current-loans" do
        assert_text @item.name
        assert_text "Overdue"
        click_on "Return"
      end

      refute_selector "#current-loans"

      within "#returned-loans" do
        assert_text @item.name
      end

      # breaks due to the time change :(
      # assert_content "$-13.00"
    end
  end

  test "renews item" do
    Time.use_zone "America/Chicago" do
      saturday = Time.new(2020, 1, 25).end_of_day
      @item = create(:item)
      @member = create(:verified_member_with_membership)
      create(:loan, item: @item, member: @member, due_at: saturday, created_at: saturday - 7.days)

      friday = Time.new(2020, 1, 24, 12, 30)

      travel_to friday do
        visit admin_member_url(@member)

        within "#current-loans" do
          assert_text @item.name
          assert_text "Due Saturday, January 25"
          click_on "Renew"
        end

        within "#current-loans" do
          refute_text "Due Saturday, January 25"
          assert_text "Due Saturday, February 1"
          assert_text @item.name
          click_on "Renew"
        end

        within "#current-loans" do
          refute_text "Due Saturday, February 1"
          assert_text "Due Saturday, February 8"
          click_on "Undo renewal"
        end

        within "#current-loans" do
          refute_text "Due Saturday, February 8"
          assert_text "Due Saturday, February 1"
          click_on "Undo renewal"
        end

        within "#current-loans" do
          refute_text "Due Saturday, February 1"
          assert_text "Due Saturday, January 25"
        end
      end
    end
  end

  test "can't renew item with max renewals" do
    Time.use_zone "America/Chicago" do
      sunday = Time.new(2020, 1, 26).end_of_day
      borrow_policy = create(:borrow_policy, renewal_limit: 0)
      @item = create(:item, borrow_policy:)
      @member = create(:verified_member_with_membership)
      create(:loan, item: @item, member: @member, due_at: sunday, created_at: sunday - 7.days)

      saturday = Time.new(2020, 1, 25, 12, 30)

      travel_to saturday do
        visit admin_member_url(@member)

        within "#current-loans" do
          assert_text @item.name
          assert_text "Due Sunday, January 26"
          assert_selector "button:disabled", text: "Renew"
        end
      end
    end
  end
end
