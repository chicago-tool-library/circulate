# frozen_string_literal: true

require "test_helper"

class ItemExporterTest < ActiveSupport::TestCase
  setup do
  end

  test "exports items" do
    create(:item)

    exporter = ItemExporter.new(Item.all)
    stream = StringIO.new
    exporter.export(stream)

    stream.rewind

    assert_equal 2, stream.read.lines.size
  end
end
