require "test_helper"

module Signup
  class DocumentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      create(:agreement_document)
      create(:document, code: "borrow_policy", body: "The borrow policy text")
    end

    test "rules renders the policy text when no deck is configured" do
      get signup_rules_url

      assert_response :success
      assert_select "iframe", count: 0
      assert_select ".rich-text", text: /The borrow policy text/
    end

    test "rules keeps the policy text while the orientation is switched off" do
      Library.first.update!(orientation_enabled: false, policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")

      get signup_rules_url

      assert_response :success
      assert_select "iframe", count: 0
      assert_select ".rich-text", text: /The borrow policy text/
    end

    test "rules embeds the policy deck when one is configured" do
      Library.first.update!(orientation_enabled: true, policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")

      get signup_rules_url

      assert_response :success
      assert_select "iframe[src='https://www.canva.com/design/ABC/xyz/view?embed']"
      assert_select "a[href='https://www.canva.com/design/ABC/xyz/view'][target=_blank]"
      assert_select "details .rich-text", text: /The borrow policy text/
    end

    test "rules links the full policy text to its Google Doc when one is set" do
      Library.first.update!(orientation_enabled: true, policy_deck_url: "https://www.canva.com/design/ABC/xyz/view")
      Document.borrow_policy.first.update!(google_doc_url: "https://docs.google.com/document/d/17XtP4kH2jPSqhEGELCz47-BpS3sYxyUb6vXDCAyYp-o/edit")

      get signup_rules_url

      assert_response :success
      assert_select "a[href='https://docs.google.com/document/d/17XtP4kH2jPSqhEGELCz47-BpS3sYxyUb6vXDCAyYp-o/edit'][target=_blank]", text: "Read the full text of our policies"
      assert_select "details", count: 0
    end

    test "rules embeds the policy Google Doc when there is no deck" do
      Document.borrow_policy.first.update!(google_doc_url: "https://docs.google.com/document/d/17XtP4kH2jPSqhEGELCz47-BpS3sYxyUb6vXDCAyYp-o/edit")

      get signup_rules_url

      assert_response :success
      assert_select ".document-embed iframe[src='https://docs.google.com/document/d/17XtP4kH2jPSqhEGELCz47-BpS3sYxyUb6vXDCAyYp-o/preview']"
      assert_select ".rich-text", count: 0
    end
  end
end
