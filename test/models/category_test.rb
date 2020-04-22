require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    category = Category.create!(name: "Hammers and Drills")

    assert_equal "hammers-and-drills", category.slug
  end

  test "loads entire tree" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)
    mitre_saws = Category.create!(name: "Mitre Saws", parent: saws)

    tree = Category.entire_tree
    assert_equal [power_tools, saws, mitre_saws], tree

    assert_equal [power_tools.id, saws.id], tree[1].path_ids
    assert_equal [power_tools.name, saws.name], tree[1].path_names

    assert_equal [power_tools.id, saws.id, mitre_saws.id], tree[2].path_ids
    assert_equal [power_tools.name, saws.name, mitre_saws.name], tree[2].path_names
  end

  test "prevents creating a loop" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)

    refute power_tools.update(parent: saws)
    assert_equal ["can't be set to a child"], power_tools.errors[:parent_id]
  end
end
