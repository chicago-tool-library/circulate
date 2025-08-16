require "application_system_test_case"

class ItemFilteringTest < ApplicationSystemTestCase
  def setup
    borrow_policy = create(:borrow_policy, :requires_approval)

    @category1 = create(:category, name: "Nailguns")
    @category1_subcategory = create(:category, parent: @category1, name: "Pneumatic")
    @category2 = create(:category, name: "Drills")

    @item1 = create(:item, categories: [@category1_subcategory], name: "Nine-Inch Nailgun", borrow_policy:)
    @item2 = create(:item, categories: [@category2], name: "Boring Borer", borrow_policy:)
    @item3 = create(:item, categories: [@category2], name: "Droll Drill")

    @member = create(:verified_member_with_membership)
    @user = @member.user
    @hold = create(:hold, member: @member, item: @item3, creator: @user)

    CategoryNode.refresh

    login_as @user
  end

  test "finds items via queries" do
    visit items_url

    fill_in "search items", with: "Nine-Inch\n"

    within(".items-summary") do
      assert_content "Searched for Nine-Inch", normalize_ws: true
      assert_content "Found 1 item."
      refute_content "Staff Approval Required"
    end

    within(".items-list") do
      assert_content "Nine-Inch Nailgun"
      refute_content "Boring Borer"
      refute_content "Droll Drill"
    end
  end

  test "finds items via categories" do
    visit items_url

    find("a", text: "Drills (2)").click

    within(".items-summary") do
      assert_content "Searched in category Drills", normalize_ws: true
      assert_content "Found 2 items."
      refute_content "Staff Approval Required"
    end

    within(".items-list") do
      assert_content "Boring Borer"
      assert_content "Droll Drill"
    end
  end

  test "filters items to only those that require approval" do
    visit items_url

    click_on "Staff Approval Required"

    within(".items-summary") do
      assert_content "Staff Approval Required"
    end

    within(".items-list") do
      assert_content "Nine-Inch Nailgun"
      assert_content "Boring Borer"
      refute_content "Droll Drill"
    end
  end

  test "finds items via both queries and categories" do
    visit items_url

    fill_in "search items", with: "Boring\n"
    within(".items-summary") do
      assert_content "Searched for Boring", normalize_ws: true
      assert_content "Found 1 item."
    end

    find("a", text: "Drills (2)").click
    within(".items-summary") do
      assert_content "Searched for Boring in category Drills", normalize_ws: true
      assert_content "Found 1 item."
    end

    within(".items-list") do
      assert_content "Boring Borer"
      refute_content "Droll Drill"
      refute_content "Nine-Inch Nailgun"
    end
  end

  test "filters to items available now" do
    visit items_url
    find("label", text: "Only show items available now").click

    within(".items-summary") do
      assert_content "Found 2 items."
    end

    within(".items-list") do
      assert_content "Boring Borer"
      refute_content "Droll Drill"
      assert_content "Nine-Inch Nailgun"
    end
  end

  test "filters items available now with a category" do
    visit items_url

    find("a", text: "Drills (2)").click
    within(".items-summary") do
      assert_content "Searched in category Drills", normalize_ws: true
      assert_content "Found 2 items."
    end

    find("label", text: "Only show items available now").click
    within(".items-summary") do
      assert_content "Found 1 item."
    end

    within(".items-list") do
      assert_content "Boring Borer"
      refute_content "Droll Drill"
      refute_content "Nine-Inch Nailgun"
    end
  end

  test "filters items available now with a search query" do
    visit items_url

    fill_in "search items", with: "Droll\n"
    within(".items-summary") do
      assert_content "Searched for Droll", normalize_ws: true
      assert_content "Found 1 item."
    end

    find("a", text: "Drills (2)").click
    within(".items-summary") do
      assert_content "Searched for Droll in category Drills", normalize_ws: true
      assert_content "Found 1 item."
    end

    find("label", text: "Only show items available now").click
    within(".items-summary") do
      assert_content "Searched for Droll in category Drills", normalize_ws: true
      assert_content "Found 0 items."
    end
  end
end
