# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    category = Category.create!(name: "Hammers and Drills")

    assert_equal "hammers-and-drills", category.slug
  end

  test "prevents creating a loop" do
    power_tools = Category.create(name: "Power Tools")
    saws = Category.create!(name: "Saws", parent: power_tools)

    assert_not power_tools.update(parent: saws)
    assert_equal ["can't be set to a child"], power_tools.errors[:parent_id]
  end
end
