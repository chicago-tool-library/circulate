require "test_helper"

class ItemSearchQueryTest < ActiveSupport::TestCase
  test "blank input has no terms or constraints" do
    query = ItemSearchQuery.new("")
    assert query.blank?
    assert_empty query.bare_terms
    assert_empty query.field_constraints
  end

  test "whitespace-only input is blank" do
    assert ItemSearchQuery.new("   \t  ").blank?
  end

  test "nil input is blank" do
    assert ItemSearchQuery.new(nil).blank?
  end

  test "single bare term" do
    query = ItemSearchQuery.new("drill")
    assert_equal ["drill"], query.bare_terms
    assert_empty query.field_constraints
  end

  test "multiple bare terms" do
    query = ItemSearchQuery.new("dewalt drill cordless")
    assert_equal %w[dewalt drill cordless], query.bare_terms
    assert_empty query.field_constraints
  end

  test "field constraint for each recognised field" do
    %w[name number brand model size strength].each do |field|
      query = ItemSearchQuery.new("#{field}:value")
      assert_empty query.bare_terms, "expected no bare terms for #{field}:value"
      assert_equal({field => "value"}, query.field_constraints)
    end
  end

  test "mixed bare term and field constraint" do
    query = ItemSearchQuery.new("brand:dewalt drill")
    assert_equal ["drill"], query.bare_terms
    assert_equal({"brand" => "dewalt"}, query.field_constraints)
  end

  test "quoted multi-word value strips surrounding quotes" do
    query = ItemSearchQuery.new('name:"power drill"')
    assert_empty query.bare_terms
    assert_equal({"name" => "power drill"}, query.field_constraints)
  end

  test "quoted bare phrase preserves spaces" do
    query = ItemSearchQuery.new('"hand saw"')
    assert_equal ["hand saw"], query.bare_terms
    assert_empty query.field_constraints
  end

  test "unknown field prefix falls through as bare term" do
    query = ItemSearchQuery.new("foo:bar")
    assert_equal ["foo:bar"], query.bare_terms
    assert_empty query.field_constraints
  end

  test "case-insensitive field prefix is normalised to lowercase" do
    query = ItemSearchQuery.new("Brand:Dewalt")
    assert_empty query.bare_terms
    assert_equal({"brand" => "Dewalt"}, query.field_constraints)
  end

  test "multiple constraints for different fields" do
    query = ItemSearchQuery.new("brand:dewalt size:large")
    assert_equal({"brand" => "dewalt", "size" => "large"}, query.field_constraints)
  end

  test "present? is the inverse of blank?" do
    assert ItemSearchQuery.new("drill").present?
    assert_not ItemSearchQuery.new("").present?
  end
end
