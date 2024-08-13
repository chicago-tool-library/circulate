require "application_system_test_case"

module Admin
  class MonthlyActivitiesTest < ApplicationSystemTestCase
    include AdminHelper

    def setup
      @date = Time.zone.parse("2022-1-1")
      travel_to @date

      # 2 new (verified) members this month and 1 pending
      january_member_1 = create(:verified_member_with_membership)
      create(:verified_member_with_membership)
      create(:complete_member, status: :pending)

      # 1 existing member from November last year
      november_member_1 = create(:verified_member_with_membership, created_at: Time.zone.parse("2021-11-1"))

      # 2 loans for the same member this month, giving us 1 active member
      january_loan_1 = create(:loan, member: january_member_1)
      january_loan_2 = create(:loan, member: january_member_1)

      # 1 loan for an old member last month, giving us 1 active member
      december_loan_1 = create(:loan, member: november_member_1, created_at: Time.zone.parse("2021-12-10"))

      # 2 appointments this month, 1 of which completed.
      create(:appointment, member: january_member_1, starts_at: Time.zone.parse("2022-1-5"),
        ends_at: Time.zone.parse("2022-1-6"), loans: [january_loan_1])
      create(:appointment, member: january_member_1, starts_at: Time.zone.parse("2022-1-27"),
        ends_at: Time.zone.parse("2022-1-28"), completed_at: Time.zone.parse("2022-1-28"), loans: [january_loan_2])

      # 1 appointment which started and was completed last month but ended this month,
      # giving us 1 for last month
      create(:appointment, member: november_member_1, starts_at: Time.zone.parse("2021-12-25"),
        ends_at: Time.zone.parse("2022-1-1"), completed_at: Time.zone.parse("2021-12-26"), loans: [december_loan_1])

      sign_in_as_admin
    end

    def teardown
    end

    # ╔═══════════════╦══════════════════════╦═════════════════════╦════════════════════════════╗
    # ║               ║ Activity             ║ Members             ║ Appointments               ║
    # ├───────────────┼──────────────────────┼─────────────────────┼────────────────────────────┤
    # ║ Month         ║ Loans     ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
    # ╠═══════════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ November 2021 ║ 0         ║ 0        ║ 1        ║ 0        ║ 0             ║ 0          ║
    # ║ December 2021 ║ 1         ║ 1        ║ 0        ║ 0        ║ 1             ║ 1          ║
    # ║ January 2022  ║ 2         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
    # ╠═══════════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ Total         ║ 3         ║ 2        ║ 3        ║ 1        ║ 3             ║ 2          ║
    # ╚═══════════════╩═══════════╩══════════╩══════════╩══════════╩═══════════════╩════════════╝
    test "table is populated accordingly" do
      visit admin_reports_monthly_activities_url

      assert_selector ".monthly-adjustments"
      within(".monthly-adjustments") do
        # ║               ║ Activity             ║ Members             ║ Appointments               ║
        within("thead > tr:nth-child(1)") do
          within("th:nth-child(2)") { assert_text("Activity") }
          within("th:nth-child(3)") { assert_text("Members") }
          within("th:nth-child(4)") { assert_text("Appointments") }
        end

        # ║ Month         ║ Loans     ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
        within("thead > tr:nth-child(2)") do
          within("th:nth-child(1)") { assert_text("Month") }

          within("th:nth-child(2)") { assert_text("Loans") }
          within("th:nth-child(3)") { assert_text("Members") }

          within("th:nth-child(4)") { assert_text("New") }
          within("th:nth-child(5)") { assert_text("Pending") }

          within("th:nth-child(6)") { assert_text("Scheduled") }
          within("th:nth-child(7)") { assert_text("Completed") }
        end

        # ║ November 2021 ║ 0         ║ 0        ║ 1        ║ 0        ║ 0             ║ 0          ║
        within("tbody > tr:nth-child(1)") do
          within("td:nth-child(1)") { assert_text("November 2021") }

          within("td:nth-child(2)") { assert_text("0") }
          within("td:nth-child(3)") { assert_text("0") }

          within("td:nth-child(4)") { assert_text("1") }
          within("td:nth-child(5)") { assert_text("0") }

          within("td:nth-child(6)") { assert_text("0") }
          within("td:nth-child(7)") { assert_text("0") }
        end

        # ║ December 2021 ║ 1         ║ 1        ║ 0        ║ 0        ║ 1             ║ 1          ║
        within("tbody > tr:nth-child(2)") do
          within("td:nth-child(1)") { assert_text("December 2021") }

          within("td:nth-child(2)") { assert_text("1") }
          within("td:nth-child(3)") { assert_text("1") }

          within("td:nth-child(4)") { assert_text("0") }
          within("td:nth-child(5)") { assert_text("0") }

          within("td:nth-child(6)") { assert_text("1") }
          within("td:nth-child(7)") { assert_text("1") }
        end

        # ║ January 2022  ║ 2         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
        within("tbody > tr:nth-child(3)") do
          within("td:nth-child(1)") { assert_text("January 2022") }

          within("td:nth-child(2)") { assert_text("2") }
          within("td:nth-child(3)") { assert_text("1") }

          within("td:nth-child(4)") { assert_text("2") }
          within("td:nth-child(5)") { assert_text("1") }

          within("td:nth-child(6)") { assert_text("2") }
          within("td:nth-child(7)") { assert_text("1") }
        end

        # ║ Total         ║ 3         ║ 2        ║ 3        ║ 1        ║ 3             ║ 2          ║
        within("tfoot > tr") do
          within("td:nth-child(1)") { assert_text("Total") }

          within("td:nth-child(2)") { assert_text("3") }
          within("td:nth-child(3)") { assert_text("2") }

          within("td:nth-child(4)") { assert_text("3") }
          within("td:nth-child(5)") { assert_text("1") }

          within("td:nth-child(6)") { assert_text("3") }
          within("td:nth-child(7)") { assert_text("2") }
        end
      end
    end
  end
end
