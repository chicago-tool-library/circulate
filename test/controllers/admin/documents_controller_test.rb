require "test_helper"

module Admin
  class DocumentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @document = create(:agreement_document)
      @user = create(:admin_user)
      sign_in @user
    end

    test "should get index" do
      get admin_documents_url
      assert_response :success
    end

    test "should show document" do
      get admin_document_url(@document)
      assert_response :success
    end

    test "should get edit" do
      get edit_admin_document_url(@document)
      assert_response :success
    end

    test "should update document" do
      patch admin_document_url(@document), params: {document: {body: @document.body, name: @document.name, summary: @document.summary}}
      assert_redirected_to admin_document_url(@document)
    end

    test "should update the Google Doc link" do
      patch admin_document_url(@document), params: {document: {google_doc_url: "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit"}}

      assert_redirected_to admin_document_url(@document)
      assert_equal "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit", @document.reload.google_doc_url
    end

    test "should reject a link that isn't a Google Doc" do
      patch admin_document_url(@document), params: {document: {google_doc_url: "https://example.com/agreement"}}

      assert_response :unprocessable_content
      assert_nil @document.reload.google_doc_url
    end
  end
end
