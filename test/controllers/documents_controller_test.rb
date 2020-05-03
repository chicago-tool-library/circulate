require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  test "views a document" do
    @document = create(:document, body: "document body")

    get document_url(@document.code)

    assert_response :success
    assert_select "h1", @document.name
    assert_select ".trix-content", "document body"
  end
end
