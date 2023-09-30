# frozen_string_literal: true

require "test_helper"

class CategoryNodeTest < ActiveSupport::TestCase
  test "loads entire tree" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)
    mitre_saws = Category.create!(name: "Mitre Saws", parent: saws)

    create(:item, categories: [power_tools])
    2.times { create(:item, categories: [saws]) }
    4.times { create(:item, categories: [mitre_saws]) }

    CategoryNode.refresh
    tree = CategoryNode.all.order("id ASC")

    assert_equal power_tools.id, tree[0].id
    assert_equal 7, tree[0].visible_items_count
    assert_equal [power_tools.id], tree[0].path_ids
    assert_equal [power_tools.name], tree[0].path_names

    assert_equal saws.id, tree[1].id
    assert_equal 6, tree[1].visible_items_count
    assert_equal [power_tools.id, saws.id], tree[1].path_ids
    assert_equal [power_tools.name, saws.name], tree[1].path_names

    assert_equal mitre_saws.id, tree[2].id
    assert_equal 4, tree[2].visible_items_count
    assert_equal [power_tools.id, saws.id, mitre_saws.id], tree[2].path_ids
    assert_equal [power_tools.name, saws.name, mitre_saws.name], tree[2].path_names
  end
end
