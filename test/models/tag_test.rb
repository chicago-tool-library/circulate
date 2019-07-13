require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "stores a slug on creation" do
    tag = Tag.new(name: "Hammers and Drills")
    tag.save!

    assert_equal "hammers-and-drills", tag.slug
  end
end
