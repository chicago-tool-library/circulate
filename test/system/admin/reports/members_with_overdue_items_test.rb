require "application_system_test_case"

class Admin::MonthlyActivitiesTest < ApplicationSystemTestCase
  include AdminHelper
  include ActionView::Helpers::NumberHelper
  include MembersHelper

  def setup
    sign_in_as_admin

    @member_without_loans = create(:member, preferred_name: "Loanless Lane")

    @member_with_non_overdue_loans = create(:member, preferred_name: "Mr. Ontime")
    create(:loan, member: @member_with_non_overdue_loans)
    create(:ended_loan, member: @member_with_non_overdue_loans)

    member_with_one_overdue_loan = create(:member, preferred_name: "(Over)Drew")
    create(:overdue_loan, member: member_with_one_overdue_loan)
    create(:loan, member: member_with_one_overdue_loan)

    member_with_multiple_overdue_loans = create(:member, preferred_name: "(Mul)Timothy")
    create_list(:overdue_loan, 3, member: member_with_multiple_overdue_loans)
    create(:loan, member: member_with_multiple_overdue_loans)
    create(:ended_loan, member: member_with_multiple_overdue_loans)

    @overdue_loan_members = [member_with_one_overdue_loan, member_with_multiple_overdue_loans]
  end

  test "the table lists the member's name, contact information, and overdue tools" do
    visit admin_reports_members_with_overdue_loans_url

    refute_text @member_without_loans.preferred_name
    refute_text @member_with_non_overdue_loans.preferred_name

    @overdue_loan_members.each do |member|
      assert_text member.preferred_name
      assert_text member.user.email
      assert_text format_phone_number(member.phone_number)

      member.overdue_loans.each do |loan|
        assert_text loan.item.name
      end
    end
    assert_equal 3, all("tr").size # 2 for members, 1 for the header
  end
end
