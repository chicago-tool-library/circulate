require "application_system_test_case"
require "securerandom"

module Organizations
  class OwnerSignupTest < ApplicationSystemTestCase
    def setup
      ActionMailer::Base.deliveries.clear
    end

    test "signs up for a new account" do
      email = "#{SecureRandom.alphanumeric}@test.com".downcase
      organization_name = "org #{SecureRandom.alphanumeric}"

      visit signup_organizations_policies_path

      assert_selector "li.step-item.active", text: "Policies"
      click_on "Continue"

      assert_selector "li.step-item.active", text: "Profile"

      fill_in "Organization Name", with: organization_name
      fill_in "Full name", with: "N. K. Jemisin"
      fill_in "Email", with: email
      fill_in "Password", with: "password", match: :prefer_exact
      fill_in "Password confirmation", with: "password", match: :prefer_exact

      perform_enqueued_jobs do # send the confirmation email
        assert_difference "User.count" => 1, "Organization.count" => 1 do
          click_on "Save and Continue"

          assert_selector "li.step-item.active", text: "Confirm Email"
          assert_content email
        end
      end

      user = User.find_by(email: email)
      assert user, "user was not created"
      refute user.confirmed?

      assert_equal 1, user.organizations.size
      assert_equal organization_name, user.organizations.first.name

      assert_emails 1
      confirmation_path = assert_delivered_email(to: email) do |html, text|
        assert_includes html, "Confirm your organization account"
        page = Capybara.string(html)
        link = page.find(:link, "Continue setting up your organization")

        uri = URI.parse(link["href"])
        "#{uri.path}?#{uri.query}"
      end

      visit confirmation_path

      assert_selector "li.step-item.active", text: "Approval"

      user.reload
      assert user.confirmed?
    end

    # /signup/organization/cost explains costs
    # /signup/organization/profile create org, user, and organization_member
    # /signup/organization/payment collect payment info
    # then we go to stripe and then are redirected back to:
    # /organizations/:id show status of organization (approved or not)

    # later on
    # /organizations/:id/payment view or collect payment information

    # maybe later we move thing under the org?
    # /organizations/:id/reservations

    # see also the following PR, which puts org signup underneath the /signup path
    # https://github.com/chicago-tool-library/circulate/compare/main...phinze/org-signup
  end
end
