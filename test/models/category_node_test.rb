require "test_helper"

class CategoryNodeTest < ActiveSupport::TestCase
  test "loads entire tree" do
    power_tools = Category.create(name: "Power Tools", item_counts: {active: 1})
    saws = Category.create!(name: "Saws", parent: power_tools, item_counts: {active: 2})
    mitre_saws = Category.create!(name: "Mitre Saws", parent: saws, item_counts: {active: 4})

    CategoryNode.refresh
    tree = CategoryNode.all.order("id ASC")

    assert_equal power_tools.id, tree[0].id
    assert_equal({"active" => 1}, tree[0].item_counts)
    assert_equal 7, tree[0].visible_items_count
    assert_equal [power_tools.id], tree[0].path_ids
    assert_equal [power_tools.name], tree[0].path_names

    assert_equal saws.id, tree[1].id
    assert_equal({"active" => 2}, tree[1].item_counts)
    assert_equal 6, tree[1].visible_items_count
    assert_equal [power_tools.id, saws.id], tree[1].path_ids
    assert_equal [power_tools.name, saws.name], tree[1].path_names

    assert_equal mitre_saws.id, tree[2].id
    assert_equal({"active" => 4}, tree[2].item_counts)
    assert_equal 4, tree[2].visible_items_count
    assert_equal [power_tools.id, saws.id, mitre_saws.id], tree[2].path_ids
    assert_equal [power_tools.name, saws.name, mitre_saws.name], tree[2].path_names
  end
end
