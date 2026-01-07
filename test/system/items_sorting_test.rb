require "application_system_test_case"

class ItemSortingTest < ApplicationSystemTestCase
  def setup
    @drill1 = create(:item, name: "Power Rad Drill", brand: "Rad Drill", number: 300, created_at: 2.days.ago)
    @drill2 = create(:item, name: "Sour Drill Rad", brand: "Rad", number: 500, created_at: 5.days.ago)
    @drill3 = create(:item, name: "Shower Random Drill", brand: "Shower", number: 200, created_at: 3.days.ago)
    @saw = create(:item, name: "Tile Rad Saw", number: 1000, created_at: 4.days.ago)

    @member = create(:verified_member_with_membership)
    @user = @member.user

    login_as @user
  end

  test "items are ordered by date added when no query or sort are provided" do
    visit items_url

    assert_selector ".btn.active", text: "Date Added"

    item_links = all(".item-name").map(&:text)

    assert_equal 4, item_links.size

    expected_item_names_order = [@drill1, @drill3, @saw, @drill2].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking date added sorts the items by date added" do
    visit items_url
    # Have to navigate to a different sort, assert the button changed, then navigate
    # back since date added is the default sort order
    click_on "Name"

    assert_selector ".btn.active", text: "Name"

    click_on "Date Added"

    assert_selector ".btn.active", text: "Date Added"

    item_links = all(".item-name").map(&:text)

    assert_equal 4, item_links.size

    expected_item_names_order = [@drill1, @drill3, @saw, @drill2].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking name sorts the items by name" do
    visit items_url
    click_on "Name"

    assert_selector ".btn.active", text: "Name"

    item_links = all(".item-name").map(&:text)

    assert_equal 4, item_links.size

    expected_item_names_order = [@drill1, @drill3, @drill2, @saw].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking number sorts the items by number" do
    visit items_url
    click_on "Number"

    assert_selector ".btn.active", text: "Number"

    item_links = all(".item-name").map(&:text)

    assert_equal 4, item_links.size

    expected_item_names_order = [@drill3, @drill1, @drill2, @saw].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking date added sorts the items by date added (with a query)" do
    visit items_url
    fill_in "search items", with: "dri\n"

    assert_selector ".btn.active", text: "Relevance"

    click_on "Date Added"

    assert_selector ".btn.active", text: "Date Added"

    item_links = all(".item-name").map(&:text)

    assert_equal 3, item_links.size

    expected_item_names_order = [@drill1, @drill3, @drill2].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking name sorts the items by name (with a query)" do
    visit items_url
    fill_in "search items", with: "dri\n"

    assert_selector ".btn.active", text: "Relevance"

    click_on "Name"

    assert_selector ".btn.active", text: "Name"

    item_links = all(".item-name").map(&:text)

    assert_equal 3, item_links.size

    expected_item_names_order = [@drill1, @drill3, @drill2].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "clicking number sorts the items by number (with a query)" do
    visit items_url
    fill_in "search items", with: "dri\n"

    assert_selector ".btn.active", text: "Relevance"

    click_on "Number"

    assert_selector ".btn.active", text: "Number"

    item_links = all(".item-name").map(&:text)

    assert_equal 3, item_links.size

    expected_item_names_order = [@drill3, @drill1, @drill2].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "there is no relevance sort button when there is no query" do
    visit items_url

    refute_text "Relevance"

    fill_in "search items", with: "Drill\n"

    assert_text "Relevance"
  end

  test "items are ordered by relevance when a query is provided but no sort is provided" do
    visit items_url
    fill_in "search items", with: "Ra Drill\n"

    assert_selector ".btn.active", text: "Relevance"

    item_links = all(".item-name").map(&:text)

    assert_equal 3, item_links.size

    expected_item_names_order = [@drill2, @drill1, @drill3].map(&:name)

    assert_equal expected_item_names_order, item_links
  end

  test "when there is no query but the sort is still set to relevance it falls back to its default" do
    visit items_url sort: "relevance"

    assert_selector ".btn.active", text: "Date Added"
  end
end
