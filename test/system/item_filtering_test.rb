# frozen_string_literal: true

require "application_system_test_case"

class ItemFilteringTest < ApplicationSystemTestCase
  def setup
    @category1 = create(:category, name: "Nailguns")
    @category1_subcategory = create(:category, parent: @category1, name: "Pneumatic")
    @category2 = create(:category, name: "Drills")

    @item1 = create(:item, categories: [@category1_subcategory], name: "Nine-Inch Nailgun")
    @item2 = create(:item, categories: [@category2], name: "Boring Borer")
    @item3 = create(:item, categories: [@category2], name: "Droll Drill")

    CategoryNode.refresh

    login_as @user
  end

  test "finds items via queries" do
    visit items_url

    fill_in "search items", with: "Nine-Inch\n"

    within(".items-summary") do
      assert_content "Searched for Nine-Inch", normalize_ws: true
      assert_content "Found 1 item."
    end

    within(".items-table") do
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
    end

    within(".items-table") do
      assert_content "Boring Borer"
      assert_content "Droll Drill"
    end
  end

  test "finds items via both queries and categories" do
    visit items_url

    fill_in "search items", with: "Boring\n"
    find("a", text: "Drills (2)").click

    within(".items-summary") do
      assert_content "Searched for Boring in category Drills", normalize_ws: true
      assert_content "Found 1 item."
    end

    within(".items-table") do
      assert_content "Boring Borer"
      refute_content "Droll Drill"
      refute_content "Nine-Inch Nailgun"
    end
  end
end
