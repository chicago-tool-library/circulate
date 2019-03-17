require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "assigns a number" do
    item = Item.new(items(:complete).attributes.except("id", "number"))
    item.save!

    assert item.number
  end
end
