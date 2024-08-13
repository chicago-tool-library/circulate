require "test_helper"

class NullItemTest < ActiveSupport::TestCase
  setup do
    @item = NullItem.new
  end

  test "item API" do
    assert_equal 0, @item.holds.active.count
    assert_equal false, @item.active?
  end
end
