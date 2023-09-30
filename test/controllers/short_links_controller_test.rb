# frozen_string_literal: true

require "test_helper"

class ShortLinksControllerTest < ActionDispatch::IntegrationTest
  test "searches with a query" do
    link = create(:short_link)

    get short_link_url(link.slug)

    assert_equal 301, response.status
    assert_redirected_to link.url
  end

  test "returns a 404 with a nonexistant slug" do
    get short_link_url("nope")

    assert_equal 404, response.status
  end
end
