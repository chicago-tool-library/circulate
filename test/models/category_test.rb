require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    category = Category.create!(name: "Hammers and Drills")

    assert_equal "hammers-and-drills", category.slug
  end

  test "prevents creating a loop" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)

    refute power_tools.update(parent: saws)
    assert_equal ["can't be set to a child"], power_tools.errors[:parent_id]
  end

  test "updates its item counts" do
    power_tools = Category.create(name: "Power Tools")

    create(:item, categories: [power_tools], status: "active")
    create(:item, categories: [power_tools], status: "active")
    create(:item, categories: [power_tools], status: "retired")

    assert_equal({"active" => 2, "maintenance" => 0, "pending" => 0, "retired" => 1}, power_tools.item_counts)
  end
end
