require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    category = Category.create!(name: "Hammers and Drills")

    assert_equal "hammers-and-drills", category.slug
  end

  test "includes immediate children" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)
    drills = Category.create!(name: "Drills", parent: power_tools)

    assert_equal [saws, drills], power_tools.descendents
  end

  test "includes both children and grandchildren" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)
    mitre_saws = Category.create!(name: "Mitre Saws", parent: saws)

    assert_equal [saws, mitre_saws], power_tools.descendents
  end
end
