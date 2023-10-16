require "test_helper"

module Signup
  class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
    test "shows confirmation message including add to contacts line" do
      create(:agreement_document)

      get signup_confirmation_url

      library = assigns(:current_library)
      add_to_contacts_regexp = /Please consider adding.*#{library.email}.*to your contacts/

      assert_match add_to_contacts_regexp, response.body
    end
  end
end
