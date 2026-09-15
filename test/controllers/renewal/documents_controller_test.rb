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

    teardown do
      ENV.delete("POLICY_DECK_URL")
    end

    test "rules embeds the policy deck when one is configured" do
      ENV["POLICY_DECK_URL"] = "https://www.canva.com/design/ABC/xyz/view"

      get renewal_rules_url

      assert_response :success
      assert_select "iframe[src='https://www.canva.com/design/ABC/xyz/view?embed']"
      assert_select "details .rich-text", text: /The borrow policy text/
    end
  end
end
