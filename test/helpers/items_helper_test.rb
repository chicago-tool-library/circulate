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

  class ItemStatusTest < ItemsHelperTest
    test "item status for an available uniquely numbered item" do
      item = create(:item)

      assert_equal ["label-success", "Available"], css_class_and_status_label(item)
    end

    test "item status for a checked out uniquely numbered item" do
      item = create(:item)
      create(:loan, item: item)
      item.reload

      assert_equal ["label-warning", "Checked Out"], css_class_and_status_label(item)
    end

    test "item status for a uniquely numbered item with a hold" do
      item = create(:item)
      create(:hold, item: item)
      item.reload

      assert_equal ["label-warning", "On Hold"], css_class_and_status_label(item)
    end

    test "item status for an uniquely numbered item with status maintenance" do
      item = create(:item, status: :maintenance)
      assert_equal ["", "In Maintenance"], css_class_and_status_label(item)
    end

    [:pending, :retired].each do |status|
      test "item status for an uniquely numbered item with status #{status}" do
        item = create(:item, status: status)
        assert_equal ["", "Unavailable"], css_class_and_status_label(item)
      end
    end

    test "item status for an available unnumbered item" do
      item = create(:uncounted_item)

      assert_equal ["label-success", "Available"], css_class_and_status_label(item)
    end

    test "item status for a checked out unnumbered item" do
      item = create(:uncounted_item)
      create(:nonexclusive_loan, item: item)
      item.reload

      assert_equal ["label-success", "Available"], css_class_and_status_label(item)
    end

    test "item status for an unnumbered item with a hold" do
      item = create(:uncounted_item)
      create(:hold, item: item)
      item.reload

      assert_equal ["label-success", "Available"], css_class_and_status_label(item)
    end

    test "item status for an unnumbered item with status maintenance" do
      item = create(:uncounted_item, status: :maintenance)
      assert_equal ["", "In Maintenance"], css_class_and_status_label(item)
    end

    [:pending, :retired].each do |status|
      test "item status for an unnumbered item with status #{status}" do
        item = create(:uncounted_item, status: status)
        assert_equal ["", "Unavailable"], css_class_and_status_label(item)
      end
    end
  end
end
