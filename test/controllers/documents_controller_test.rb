require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  test "views a document" do
    @document = create(:document, body: "document body")

    get document_url(@document.code)

    assert_response :success
    assert_select "h1", @document.name
    assert_select ".trix-content", "document body"
  end

  test "embeds the Google Doc for a document that has one" do
    document = create(:document, body: "document body", google_doc_url: "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit")

    get document_url(document.code)

    assert_response :success
    assert_select ".document-embed iframe[src='https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/preview']"
    assert_select ".trix-content", count: 0
  end
end
