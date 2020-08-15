require "application_system_test_case"

module Holds
  class HoldsTest < ApplicationSystemTestCase
    include ActionView::RecordIdentifier

    def setup
      # ActionMailer::Base.deliveries.clear
      @drill1 = create(:item, name: "Drill 1")
      @drill2 = create(:item, name: "Drill 2")

      @member = create(:verified_member)

      Time.use_zone("America/Chicago") do
        day = Date.parse("2020-08-15")
        create(:event, start: day + 10.hours, finish: day + 11.hours)
        create(:event, start: day + 11.hours, finish: day + 12.hours)
      end
    end

    test "search for items and place on hold" do
      travel_to Date.parse("2020-08-13") do
        visit holds_url

        assert_text "Search for items below"
        # assert_button "Continue", disabled: true

        fill_in "query", with: "drill"

        within "#" + dom_id(@drill1) do
          click_on "Request"

          assert_button "Requested", disabled: true
        end

        click_on "Continue"

        assert_text "You are requesting this item"
        assert_text @drill1.complete_number

        fill_in "Member email", with: @member.email
        fill_in "Zipcode", with: @member.postal_code

        select "Saturday, August 15, between 10am & 11am", from: "Pick up time"
        fill_in "Questions about tools or your project", with: "I am looking to make some holes"

        assert_difference "HoldRequest.count" do
          click_button "Submit Request"

          assert_text "Hold Request Complete"
          assert_text @drill1.complete_number
          assert_text "Saturday, August 15, between 10am & 11am"
        end

        visit holds_url

        refute_text "You have selected" # ensure the cart was emptied
      end
    end

    #   test "signup and pay through square", :remote do
    #     complete_first_three_steps

    #     fill_in "Your membership fee:", with: "42"
    #     click_on "Pay Online Now"

    #     # On Square site

    #     assert_selector "h1", text: "Checkout", wait: 10 # cart needs a little while to fully load
    #     assert_selector ".order-details-section", text: "1 × Annual Membership"

    #     fill_in "card_fullname", with: "N. K. Jemisin"

    #     page.within_frame("sq-card-number") { page.first("input").fill_in with: "4111111111111111" }
    #     page.within_frame("sq-expiration-date") { page.find("input").fill_in with: "1221" }
    #     page.within_frame("sq-cvv") { page.find("input").fill_in with: "123" }
    #     page.within_frame("sq-postal-code") { page.first("input").fill_in with: "60647" }

    #     perform_enqueued_jobs do
    #       click_on "Place Order"

    #       # Back in the app
    #       assert_selector "li.step-item.active", text: "Complete", wait: 10
    #     end

    #     assert_content "Your payment of $42.00"
    #     assert_content "See you at the library!"

    #     assert_emails 1
    #     assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
    #       assert_includes html, "Thank you for signing up"
    #       assert_includes html, "Your payment of $42.00"
    #     end
    #   end

    #   test "signup and redeem a gift membership" do
    #     complete_first_three_steps
    #     gift_membership = create(:gift_membership)

    #     click_on "Redeem Gift Membership"

    #     fill_in "signup_redemption_code", with: gift_membership.code.value

    #     perform_enqueued_jobs do
    #       click_on "Redeem"

    #       assert_content "See you at the library!", wait: 10
    #     end
    #     refute_content "Your payment"

    #     assert_emails 1
    #     assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
    #       assert_includes html, "Thank you for signing up"
    #       refute_includes html, "Your payment"
    #     end

    #     assert_equal 0, Member.last.adjustments.count
    #   end
  end
end
