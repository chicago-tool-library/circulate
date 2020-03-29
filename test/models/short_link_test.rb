require "test_helper"

class ShortLinkTest < ActiveSupport::TestCase
  test "raises an exception when it can not find a unique slug" do
    link = ShortLink.new(url: "http://example.com")

    def link.unique_slug?(slug)
      false
    end

    assert_raises "could not find a unique slug" do
      link.save
    end
  end

  test "generates a unique slug when created" do
    link = ShortLink.create!(url: "http://example.com")

    refute_nil link.slug
    assert_size 6, link.slug
  end

  test "attempts to find another slug when one is taken" do
    link = ShortLink.create!(url: "http://example.com")
    second_link = ShortLink.new(url: "http://example.test")

    second_link.stub :random_slug, ReturnValues.new(link.slug, "abcdef") do
      second_link.save
    end

    assert_equal "abcdef", second_link.slug
  end

  test "records views" do
    link = create(:short_link)
    assert_equal 0, link.views
    link.record_view
    link.reload
    assert_equal 1, link.views
  end

  test "requires url" do
    link = ShortLink.new
    refute link.valid?
    assert_size 1, link.errors[:url]
  end

  test "requires valid url" do
    link = ShortLink.new(url: "notAvalidURL")
    refute link.valid?
    assert_size 1, link.errors[:url]
  end

  test "requires unique url" do
    link = create(:short_link)
    dupe_link = ShortLink.new(url: link.url)
    refute dupe_link.valid?
    assert_size 1, dupe_link.errors[:url]
  end

  test "one per URL" do
    url = "https://example.com"
    link = ShortLink.for_url(url)

    assert_difference "ShortLink.count", 0 do
      dupe_link = ShortLink.for_url(url)

      assert_equal dupe_link, link
    end
  end
end
