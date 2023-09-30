# frozen_string_literal: true

require "test_helper"

class ManualImportTest < ActiveSupport::TestCase
  URL = "https://www.singer.com/sites/default/files/outdated_product/SINGER%205500_5400_6160_6180_6199%20Sewing%20Machines.pdf"

  test "loads a file", :remote do
    skip "incompatible with new item attachments"

    manual_import = ManualImport.new(url: URL)
    assert manual_import.valid?

    item = create(:item)
    manual_import.update_item!(item)

    item.reload

    assert_equal "P209_085_trilingual_04.pdf", item.manual.filename.to_s
    assert_equal "application/pdf", item.manual.content_type
    assert_equal 2598965, item.manual.byte_size
  end

  test "is invalid without a URL" do
    manual_import = ManualImport.new(url: "not a real url")
    assert_not manual_import.valid?
    assert_equal ["must be a valid URL"], manual_import.errors[:url]
  end

  test "is invalid when a file isn't found at the URL", :remote do
    manual_import = ManualImport.new(url: "http://not.a.real.website/some/file.pdf")
    assert_not manual_import.valid?
    assert_equal ["could not be loaded"], manual_import.errors[:url]
  end
end
