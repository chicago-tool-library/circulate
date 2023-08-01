require "test_helper"

class MemberExporterTest < ActiveSupport::TestCase
  test "exports Members" do
    create(:membership, started_at: Date.new(2020, 3, 4))

    exporter = MemberExporter.new
    stream = StringIO.new
    exporter.export(stream)

    stream.rewind

    assert_equal 2, stream.read.lines.size
  end
end
