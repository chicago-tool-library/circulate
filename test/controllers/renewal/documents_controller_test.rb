require "test_helper"

module Renewal
  class DocumentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      create(:agreement_document)
      create(:document, code: "borrow_policy", body: "The borrow policy text")
      @member = create(:verified_member)
      sign_in @member.user
    end

    test "rules embeds the policy deck when one is configured" do
      Library.first.update!(orientation_enabled: true, policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")

      get renewal_rules_url

      assert_response :success
      assert_select "iframe[src='https://www.canva.com/design/ABC/xyz/view?embed']"
      assert_select "details .rich-text", text: /The borrow policy text/
    end

    test "agreement embeds the Google Doc above the acceptance checkbox" do
      Document.agreement.first.update!(google_doc_url: "https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit")

      get renewal_agreement_url

      assert_response :success
      assert_select ".document-embed iframe[src='https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/preview']"
      assert_select ".document-embed a[href='https://docs.google.com/document/d/1V1fjYCA8Op3D1NNVGKMpVHrbsSYQ33_dyZ5lt4ImAvg/edit'][target=_blank]"
      assert_select "label", text: /I have read, understand, and agree to these terms/
    end
  end
end
