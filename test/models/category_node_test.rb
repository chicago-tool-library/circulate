require "test_helper"

class CategoryNodeTest < ActiveSupport::TestCase
  test "loads entire tree" do
    power_tools = Category.create(name: "Power Tools", categorizations_count: 1)
    saws = Category.create!(name: "Saws", parent: power_tools, categorizations_count: 2)
    mitre_saws = Category.create!(name: "Mitre Saws", parent: saws, categorizations_count: 4)

    tree = CategoryNode.all

    assert_equal power_tools.id, tree[0].id
    assert_equal 1, tree[0].categorizations_count
    assert_equal 7, tree[0].tree_categorizations_count
    assert_equal [power_tools.id], tree[0].path_ids
    assert_equal [power_tools.name], tree[0].path_names

    assert_equal saws.id, tree[1].id
    assert_equal 2, tree[1].categorizations_count
    assert_equal 6, tree[1].tree_categorizations_count
    assert_equal [power_tools.id, saws.id], tree[1].path_ids
    assert_equal [power_tools.name, saws.name], tree[1].path_names

    assert_equal mitre_saws.id, tree[2].id
    assert_equal 4, tree[2].categorizations_count
    assert_equal 4, tree[2].tree_categorizations_count
    assert_equal [power_tools.id, saws.id, mitre_saws.id], tree[2].path_ids
    assert_equal [power_tools.name, saws.name, mitre_saws.name], tree[2].path_names
  end
end
