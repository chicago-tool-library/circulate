# frozen_string_literal: true

require "test_helper"

class NullItemTest < ActiveSupport::TestCase
  setup do
    @item = NullItem.new
  end

  test "item API" do
    @item.holds.active.count
    @item.active?
  end
end
