require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  DOC_URL = "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit?usp=sharing"

  test "builds the embed URL from a shared Google Doc link" do
    document = build(:document, google_doc_url: DOC_URL)

    assert document.valid?
    assert document.google_doc?
    assert_equal "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/preview", document.google_doc_embed_url
  end

  test "has no Google Doc when the link is blank" do
    document = build(:document, google_doc_url: "  ")

    assert document.valid?
    assert_nil document.google_doc_url
    refute document.google_doc?
    assert_nil document.google_doc_embed_url
  end

  test "rejects a Publish to web link, whose path has no doc ID" do
    document = build(:document, google_doc_url: "https://docs.google.com/document/d/e/2PACX-1vQexampleexampleexampleexample/pub")

    refute document.valid?
    assert document.errors.of_kind?(:google_doc_url, :invalid)
  end

  test "rejects links that aren't Google Docs" do
    document = build(:document, google_doc_url: "https://drive.google.com/file/d/abc/view")

    refute document.valid?
    assert document.errors.of_kind?(:google_doc_url, :invalid)
  end
end
