# frozen_string_literal: true

require "test_helper"

class PageAttributesTest < ActiveSupport::TestCase
  def self.helper_method(_name)
  end

  include PageAttributes

  test "sets and retrieves page attributes" do
    set_page_attr :title, "important things"

    assert_equal "important things", page_attr(:title)
    assert page_attr?(:title)
  end

  test "handles attributes that aren't set" do
    assert_nil page_attr(:title)
    assert_not page_attr?(:title)
  end
end
