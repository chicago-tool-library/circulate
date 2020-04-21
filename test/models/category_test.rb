require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    category = Category.new(name: "Hammers and Drills")
    category.save!

    assert_equal "hammers-and-drills", category.slug
  end
end
