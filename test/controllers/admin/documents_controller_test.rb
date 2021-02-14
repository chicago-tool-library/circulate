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
  end
end
