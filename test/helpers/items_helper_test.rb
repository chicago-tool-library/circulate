require "test_helper"

class ItemsHelperTest < ActionView::TestCase
  class ItemImageURLTest < ItemsHelperTest
    def stub_imagekit_url(&block)
      ENV["IMAGEKIT_URL"] = "https://ik.example.com/example/"
      block.call
    ensure
      ENV.delete "IMAGEKIT_URL"
    end

    setup do
      @item = create(:item, :with_image)
      @image = @item.image
    end

    test "returns the URL for an image without ImageKit" do
      def @image.variant(options)
        "#{filename}?#{options.to_query}"
      end

      assert_equal "tool-image.jpg?", item_image_url(@image)
    end

    test "returns the URL for a rotated image without ImageKit" do
      @image.metadata["rotation"] = "90"
      @image.save!

      def @image.variant(options)
        "#{filename}?#{options.to_query}"
      end

      assert_equal "tool-image.jpg?rotate=90", item_image_url(@image)
    end

    test "returns the URL for a resized rotated image without ImageKit" do
      @image.metadata["rotation"] = "90"
      @image.save!

      def @image.variant(options)
        "#{filename}?#{options.to_query}"
      end

      assert_equal "tool-image.jpg?#{{resize_to_limit: [80, 90], rotate: 90}.to_query}",
        item_image_url(@image, resize_to_limit: [80, 90])
    end

    test "returns the URL for an image given dimensions with ImageKit" do
      stub_imagekit_url do
        assert_equal "https://ik.example.com/example/#{@image.key}?tr=w-100,h-100,c-at_max",
          item_image_url(@image, resize_to_limit: [100, 100])
      end
    end

    test "returns the URL for a rotated image with ImageKit" do
      @image.metadata["rotation"] = "90"
      @image.save!

      stub_imagekit_url do
        assert_equal "https://ik.example.com/example/#{@image.key}?rt-90", item_image_url(@image)
      end
    end

    test "returns the URL for a rotated image given dimensions with ImageKit" do
      @image.metadata["rotation"] = "90"
      @image.save!

      stub_imagekit_url do
        assert_equal "https://ik.example.com/example/#{@image.key}?tr=w-100,h-100,c-at_max,rt-90",
          item_image_url(@image, resize_to_limit: [100, 100])
      end
    end

    test "returns the URL for an image with ImageKit" do
      stub_imagekit_url do
        assert_equal "https://ik.example.com/example/#{@image.key}",
          item_image_url(@image)
      end
    end
  end

  class StatusLabelTest < ItemsHelperTest
    test "the item status label names the status" do
      assert_equal "Active", label_text(item_status_label(create(:item)))
    end

    test "the item status label includes why an item was retired" do
      assert_equal "Retired (Broken)", label_text(item_status_label(create(:item, :retired)))
    end

    test "the borrow status label names the borrow status" do
      item = create(:item)
      create(:loan, item: item)

      assert_equal "Checked Out", label_text(borrow_status_label(item.reload))
    end

    test "the borrow status label is shown for items still in circulation" do
      assert_equal "Available", label_text(borrow_status_label(create(:item)))
      assert_equal "Available", label_text(borrow_status_label(create(:item, :maintenance)))
    end

    test "the borrow status label is not shown for items out of circulation" do
      assert_nil borrow_status_label(create(:item, status: :pending))
      assert_nil borrow_status_label(create(:item, status: :missing))
      assert_nil borrow_status_label(create(:item, :retired))
    end

    test "the admin labels are identified by a tooltip" do
      assert_equal "item status", tooltip(item_status_label(create(:item)))
      assert_equal "borrow status", tooltip(borrow_status_label(create(:item)))
    end

    test "the single label members see has no tooltip" do
      assert_nil tooltip(member_item_status_label(create(:item)))
      assert_nil tooltip(member_item_status_label(create(:item, :maintenance)))
    end

    test "members see the borrow status of an active item" do
      item = create(:item)
      create(:hold, item: item)

      assert_equal "On Hold", label_text(member_item_status_label(item.reload))
    end

    test "members see why an item that has left circulation can't be borrowed" do
      assert_equal "In Maintenance", label_text(member_item_status_label(create(:item, :maintenance)))
      assert_equal "Unavailable", label_text(member_item_status_label(create(:item, status: :pending)))
      assert_equal "Unavailable", label_text(member_item_status_label(create(:item, status: :missing)))
      assert_equal "Unavailable", label_text(member_item_status_label(create(:item, :retired)))
    end

    private

    def label_text(label)
      Nokogiri::HTML5.fragment(label).text.strip
    end

    def tooltip(label)
      Nokogiri::HTML5.fragment(label).at_css("span")["data-tooltip"]
    end
  end

  class ItemStatusOptionsTest < ItemsHelperTest
    test "it is all item statuses and descriptions" do
      assert_includes item_status_options, ["Pending (just acquired; not ready to loan)", "pending"]
      assert_includes item_status_options, ["Active (available to loan)", "active"]
      assert_includes item_status_options, ["Maintenance (undergoing maintenance; do not loan)", "maintenance"]
      assert_includes item_status_options, ["Missing (misplaced; unable to loan)", "missing"]
      assert_includes item_status_options, ["Retired (no longer part of our inventory)", "retired"]
    end

    test "it is all item statuses and descriptions except for those that are marked as disabled" do
      result = item_status_options(disabled_statuses: %w[maintenance retired])
      assert_includes result, ["Maintenance (undergoing maintenance; do not loan)", "maintenance", {disabled: true}]
      assert_includes result, ["Retired (no longer part of our inventory)", "retired", {disabled: true}]
      assert_includes result, ["Pending (just acquired; not ready to loan)", "pending"]
      assert_includes result, ["Active (available to loan)", "active"]
      assert_includes result, ["Missing (misplaced; unable to loan)", "missing"]
    end
  end
end
