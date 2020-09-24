require "application_system_test_case"

module Holds
  class HoldsTest < ApplicationSystemTestCase
    include ActionView::RecordIdentifier

    def setup
      ActionMailer::Base.deliveries.clear
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
        find "a[disabled]", text: "Continue"

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
          perform_enqueued_jobs do
            click_button "Submit Request"

            assert_text "Hold Request Complete"
            assert_text @drill1.complete_number
            assert_text "Saturday, August 15, between 10am & 11am"
          end
        end

        assert_emails 1
        assert_delivered_email(to: @member.email) do |html, text|
          assert_includes html, "Your recent holds"
          assert_includes html, "Saturday, August 15, between 10am & 11am"
          assert_includes html, @drill1.complete_number
        end

        visit holds_url

        refute_text "You have selected" # ensure the cart was emptied
      end
    end

    test "search for checked out items and place on hold" do
      travel_to Date.parse("2020-08-13") do
        @member = create(:verified_member_with_membership)
        create(:loan, item: @drill1, member: @member)

        visit holds_url

        assert_text "Search for items below"
        find "a[disabled]", text: "Continue"

        fill_in "query", with: "drill"

        within "#" + dom_id(@drill1) do
          assert_content "Checked Out"

          click_on "Request"

          assert_button "Requested", disabled: true
        end

        within "#" + dom_id(@drill2) do
          click_on "Request"

          assert_button "Requested", disabled: true
        end

        click_on "Continue"

        assert_text "You are requesting these items"
        assert_text @drill1.complete_number
        assert_text @drill2.complete_number

        assert_text "checked out or on hold for other members"

        fill_in "Member email", with: @member.email
        fill_in "Zipcode", with: @member.postal_code

        assert_select "Pick up time", disabled: true
        fill_in "Questions about tools or your project", with: "I am looking to make some holes"

        assert_difference "HoldRequest.count" do
          perform_enqueued_jobs do
            click_button "Submit Request"

            assert_text "Hold Request Complete"
            assert_text @drill1.complete_number
            assert_text "email you when they are ready"
          end
        end

        assert_emails 1
        assert_delivered_email(to: @member.email) do |html, text|
          assert_includes html, "Your recent holds"
          assert_includes html, "email you when they are ready"
          assert_includes html, @drill1.complete_number
          assert_includes html, @drill2.complete_number
        end

        visit holds_url

        refute_text "You have selected" # ensure the cart was emptied
      end
    end
  end
end
