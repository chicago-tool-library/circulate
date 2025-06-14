require "application_system_test_case"

class ItemSearchTest < ApplicationSystemTestCase
  def setup
    @nailguns = create(:category, name: "Nailguns")
    @nailguns_pneumatic = create(:category, parent: @nailguns, name: "Pneumatic")
    @drills = create(:category, name: "Drills")
    @drills_corded = create(:category, parent: @drills, name: "Corded Drills")
    @drills_cordless = create(:category, parent: @drills, name: "Cordless Drills")
    @drills_corded_really_long = create(:category, parent: @drills_corded, name: "Really Long Corded Drills")
    @screwdrivers = create(:category, name: "Screw Drivers")

    @item1 = create(:item, categories: [@nailguns_pneumatic], name: "Nine-Inch Nailgun")
    @item2 = create(:item, categories: [@drills_corded], name: "Boring Borer")
    @item3 = create(:item, categories: [@drills_cordless], name: "Droll Drill")
    @item4 = create(:item, categories: [@screwdrivers], name: "Screwy Driver")
    @item5 = create(:item, categories: [@drills_corded_really_long], name: "Droll Drill (with long cord)")

    CategoryNode.refresh
  end

  def toggle_category(category)
    find("[data-id='#{category.id}'] > button").click
  end

  test "a user can toggle categories and subcategories" do
    visit items_path

    within(".tree-nav") do
      # Only Categories
      assert_text @nailguns.name
      assert_text @drills.name
      assert_text @screwdrivers.name
      refute_text @nailguns_pneumatic.name
      refute_text @drills_corded.name
      refute_text @drills_cordless.name
      refute_text @drills_corded_really_long.name

      toggle_category(@drills)

      # All Categories and some Sub-Categories
      assert_text @nailguns.name
      assert_text @drills.name
      assert_text @screwdrivers.name
      refute_text @nailguns_pneumatic.name
      assert_text @drills_corded.name
      assert_text @drills_cordless.name
      refute_text @drills_corded_really_long.name

      toggle_category(@drills_corded)
      toggle_category(@nailguns)

      # All Categories and Sub-Categories
      assert_text @nailguns.name
      assert_text @drills.name
      assert_text @screwdrivers.name
      assert_text @nailguns_pneumatic.name
      assert_text @drills_corded.name
      assert_text @drills_cordless.name
      assert_text @drills_corded_really_long.name

      toggle_category(@drills_corded)
      toggle_category(@nailguns)

      # All Categories and some Sub-Categories
      assert_text @nailguns.name
      assert_text @drills.name
      assert_text @screwdrivers.name
      refute_text @nailguns_pneumatic.name
      assert_text @drills_corded.name
      assert_text @drills_cordless.name
      refute_text @drills_corded_really_long.name
    end
  end
end
