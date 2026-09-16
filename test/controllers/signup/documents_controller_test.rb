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
  end
end
