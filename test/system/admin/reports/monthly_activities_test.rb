require "application_system_test_case"

module Admin
  class MonthlyActivitiesTest < ApplicationSystemTestCase
    include AdminHelper

    setup do
      @date = Time.zone.parse("2022-1-15")
      travel_to @date

      # 2 new (verified) members this month and 1 pending
      january_member_1 = create(:verified_member_with_membership)
      create(:verified_member_with_membership)
      create(:complete_member, status: :pending)

      # 1 existing member from November last year
      november_member_1 = create(:verified_member_with_membership, created_at: Time.zone.parse("2021-11-1"))

      # 3 loans (1 renewal) for the same member this month, giving us 1 active member
      january_loan_1 = create(:loan, member: january_member_1)
      january_loan_2 = create(:loan, member: january_member_1, due_at: 1.week.ago, ended_at: 1.week.ago, created_at: 8.days.ago)
      january_loan_3 = create(:loan, initial_loan: january_loan_2, member: january_member_1, renewal_count: 1, item: january_loan_2.item)

      # 1 loan for an old member last month, giving us 1 active member
      december_loan_1 = create(:loan, member: november_member_1, created_at: Time.zone.parse("2021-12-10"))

      # 2 appointments this month, 1 of which completed.
      create(:appointment, member: january_member_1, starts_at: Time.zone.parse("2022-1-5"),
        ends_at: Time.zone.parse("2022-1-6"), loans: [january_loan_1])
      create(:appointment, member: january_member_1, starts_at: Time.zone.parse("2022-1-27"),
        ends_at: Time.zone.parse("2022-1-28"), completed_at: Time.zone.parse("2022-1-28"), loans: [january_loan_3])

      # 1 appointment which started and was completed last month but ended this month,
      # giving us 1 for last month
      create(:appointment, member: november_member_1, starts_at: Time.zone.parse("2021-12-25"),
        ends_at: Time.zone.parse("2022-1-1"), completed_at: Time.zone.parse("2021-12-26"), loans: [december_loan_1])

      sign_in_as_admin
    end

    # Table for 2021
    # ╔═══════════════╦══════════════════════════════════╦═════════════════════╦════════════════════════════╗
    # ║               ║ Activity                         ║ Members             ║ Appointments               ║
    # ├───────────────┼──────────────────────────────────┼─────────────────────┼────────────────────────────┤
    # ║ Month         ║ Loans     ║ Renewals  ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
    # ╠═══════════════╬═══════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ November      ║ 0         ║ 0         ║ 0        ║ 1        ║ 0        ║ 0             ║ 0          ║
    # ║ December      ║ 1         ║ 0         ║ 1        ║ 0        ║ 0        ║ 1             ║ 1          ║
    # ╠═══════════════╬═══════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ Total         ║ 1         ║ 0         ║ 1        ║ 1        ║ 0        ║ 1             ║ 1          ║
    # ╚═══════════════╩═══════════╩═══════════╩══════════╩══════════╩══════════╩═══════════════╩════════════╝
    # Table for 2022
    # ╔═══════════════╦══════════════════════════════════╦═════════════════════╦════════════════════════════╗
    # ║               ║ Activity                         ║ Members             ║ Appointments               ║
    # ├───────────────┼──────────────────────────────────┼─────────────────────┼────────────────────────────┤
    # ║ Month         ║ Loans     ║ Renewals  ║ Members  ║ New      ║ Pending  ║ Scheduled     ║ Completed  ║
    # ╠═══════════════╬═══════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ January       ║ 3         ║ 1         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
    # ╠═══════════════╬═══════════╬═══════════╬══════════╬══════════╬══════════╬═══════════════╬════════════╣
    # ║ Total         ║ 3         ║ 1         ║ 1        ║ 2        ║ 1        ║ 2             ║ 1          ║
    # ╚═══════════════╩═══════════╩═══════════╩══════════╩══════════╩══════════╩═══════════════╩════════════╝
    test "table is populated accordingly" do
      visit admin_reports_monthly_activities_url

      assert_selector "#year-2021"
      assert_selector "#year-2022"

      # table headings
      ["#year-2021", "#year-2022"].each do |selector|
        within("#year-2021") do
          within("thead > tr:nth-child(1)") do
            within("th:nth-child(2)") { assert_text("Activity") }
            within("th:nth-child(3)") { assert_text("Members") }
            within("th:nth-child(4)") { assert_text("Appointments") }
          end

          within("thead > tr:nth-child(2)") do
            within("th:nth-child(1)") { assert_text("Month") }

            within("th:nth-child(2)") { assert_text("Loans") }
            within("th:nth-child(3)") { assert_text("Renewals") }
            within("th:nth-child(4)") { assert_text("Members") }

            within("th:nth-child(5)") { assert_text("New") }
            within("th:nth-child(6)") { assert_text("Pending") }

            within("th:nth-child(7)") { assert_text("Scheduled") }
            within("th:nth-child(8)") { assert_text("Completed") }
          end
        end
      end

      within("#year-2021") do
        within("tbody > tr:nth-child(1)") do
          within("td.month") { assert_text("November") }

          within("td.loans_count-2021-11") { assert_text("0") }
          within("td.renewals_count-2021-11") { assert_text("0") }
          within("td.active_members_count-2021-11") { assert_text("0") }
          within("td.new_members_count-2021-11") { assert_text("1") }
          within("td.pending_members_count-2021-11") { assert_text("0") }
          within("td.appointments_count-2021-11") { assert_text("0") }
          within("td.completed_appointments_count-2021-11") { assert_text("0") }
        end

        within("tbody > tr:nth-child(2)") do
          within("td.month") { assert_text("December") }

          within("td.loans_count-2021-12") { assert_text("1") }
          within("td.renewals_count-2021-12") { assert_text("0") }
          within("td.active_members_count-2021-12") { assert_text("1") }
          within("td.new_members_count-2021-12") { assert_text("0") }
          within("td.pending_members_count-2021-12") { assert_text("0") }
          within("td.appointments_count-2021-12") { assert_text("1") }
          within("td.completed_appointments_count-2021-12") { assert_text("1") }
        end

        within("tfoot > tr") do
          within("td.total") { assert_text("Total") }

          within("td.loans_count-2021") { assert_text("1") }
          within("td.renewals_count-2021") { assert_text("0") }
          within("td.active_members_count-2021") { assert_text("1") }
          within("td.new_members_count-2021") { assert_text("1") }
          within("td.pending_members_count-2021") { assert_text("0") }
          within("td.appointments_count-2021") { assert_text("1") }
          within("td.completed_appointments_count-2021") { assert_text("1") }
        end
      end

      within("#year-2022") do
        within("tbody > tr:nth-child(1)") do
          within("td.month") { assert_text("January") }

          within("td.loans_count-2022-1") { assert_text("3") }
          within("td.renewals_count-2022-1") { assert_text("1") }
          within("td.active_members_count-2022-1") { assert_text("1") }
          within("td.new_members_count-2022-1") { assert_text("2") }
          within("td.pending_members_count-2022-1") { assert_text("1") }
          within("td.appointments_count-2022-1") { assert_text("2") }
          within("td.completed_appointments_count-2022-1") { assert_text("1") }
        end

        within("tfoot > tr") do
          within("td.total") { assert_text("Total") }

          within("td.loans_count-2022") { assert_text("3") }
          within("td.renewals_count-2022") { assert_text("1") }
          within("td.active_members_count-2022") { assert_text("1") }
          within("td.new_members_count-2022") { assert_text("2") }
          within("td.pending_members_count-2022") { assert_text("1") }
          within("td.appointments_count-2022") { assert_text("2") }
          within("td.completed_appointments_count-2022") { assert_text("1") }
        end
      end
    end
  end
end
