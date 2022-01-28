require "application_system_test_case"

module Admin
  class AppointmentsTest < ApplicationSystemTestCase
    include AdminHelper

    def setup
      @date = DateTime.new(2022, 1, 1)
      travel_to @date

      # 2 new (verified) members this month and 1 pending
      january_member_1 = create(:verified_member_with_membership)
      create(:verified_member_with_membership)
      create(:complete_member, status: :pending)

      # 1 existing member from November last year
      november_member_1 = create(:verified_member_with_membership, created_at: DateTime.new(2020, 11, 1))

      # 2 loans for the same member this month, giving us 1 active member
      january_loan_1 = create(:loan, member: january_member_1)
      january_loan_2 = create(:loan, member: january_member_1)

      # 1 loan for an old member last month, giving us 1 active member
      december_loan_1 = create(:loan, member: november_member_1, created_at: DateTime.new(2021, 12, 10))

      # 2 appointments this month, 1 of which completed.
      create(:appointment, member: january_member_1, starts_at: DateTime.new(2022, 1, 5),
        ends_at: DateTime.new(2022, 1, 6), loans: [january_loan_1])
      create(:appointment, member: january_member_1, starts_at: DateTime.new(2022, 1, 27),
        ends_at: DateTime.new(2022, 1, 28), completed_at: DateTime.new(2022, 1, 28), loans: [january_loan_2])

      # 1 appointment which started last month and ended this month, giving us 1 for last month
      create(:appointment, member: november_member_1, starts_at: DateTime.new(2021, 12, 25),
        ends_at: DateTime.new(2021, 12, 26), completed_at: DateTime.new(2022, 1, 1), loans: [december_loan_1])

      sign_in_as_admin
    end

    def teardown
      travel_back
    end

    # ╔═══════════════╦══════════════════════╦═════════════════════╦════════════════════════════╗
    # ║               ║ Activity             ║ Members             ║ Appointments               ║
    # ├───────────────┼──────────────────────┼─────────────────────┼────────────────────────────┤
    # ║ Month         ║ Loans     ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
    # ╠═══════════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ December 2021 ║ 1         ║ 1        ║ 0        ║ 0        ║ 1             ║ 1          ║
    # ║ January 2022  ║ 2         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
    # ╠═══════════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ Total         ║ 3         ║ 2        ║ 2        ║ 1        ║ 3             ║ 2          ║
    # ╚═══════════════╩═══════════╩══════════╩══════════╩══════════╩═══════════════╩════════════╝
    test "table is populated accordingly" do
      visit admin_reports_monthly_activities_url

      within(".monthly-adjustments") do
        # ║               ║ Activity             ║ Members             ║ Appointments               ║
        within("thead > tr:nth-child(1)") do
          find("th:nth-child(2)").assert_text("Activity")
          find("th:nth-child(3)").assert_text("Members")
          find("th:nth-child(4)").assert_text("Appointments")
        end

        # ║ Month         ║ Loans     ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
        within("thead > tr:nth-child(2)") do
          find("th:nth-child(1)").assert_text("Month")

          find("th:nth-child(2)").assert_text("Loans")
          find("th:nth-child(3)").assert_text("Members")

          find("th:nth-child(4)").assert_text("New")
          find("th:nth-child(5)").assert_text("Pending")

          find("th:nth-child(6)").assert_text("Scheduled")
          find("th:nth-child(7)").assert_text("Completed")
        end

        # ║ December 2021 ║ 1         ║ 1        ║ 0        ║ 0        ║ 1             ║ 1          ║
        within("tbody > tr:nth-child(1)") do
          find("td:nth-child(1)").assert_text("December 2021")

          find("td:nth-child(2)").assert_text("1")
          find("td:nth-child(3)").assert_text("1")

          find("td:nth-child(4)").assert_text("0")
          find("td:nth-child(5)").assert_text("0")

          find("td:nth-child(6)").assert_text("1")
          find("td:nth-child(7)").assert_text("1")
        end

        # ║ January 2022  ║ 2         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
        within("tbody > tr:nth-child(2)") do
          find("td:nth-child(1)").assert_text("January 2022")

          find("td:nth-child(2)").assert_text("2")
          find("td:nth-child(3)").assert_text("1")

          find("td:nth-child(4)").assert_text("2")
          find("td:nth-child(5)").assert_text("1")

          find("td:nth-child(6)").assert_text("2")
          find("td:nth-child(7)").assert_text("1")
        end

        # ║ Total         ║ 3         ║ 2        ║ 2        ║ 1        ║ 3             ║ 2          ║
        within("tfoot > tr") do
          find("td:nth-child(1)").assert_text("Total")

          find("td:nth-child(2)").assert_text("3")
          find("td:nth-child(3)").assert_text("2")

          find("td:nth-child(4)").assert_text("2")
          find("td:nth-child(5)").assert_text("1")

          find("td:nth-child(6)").assert_text("3")
          find("td:nth-child(7)").assert_text("2")
        end
      end
    end
  end
end
