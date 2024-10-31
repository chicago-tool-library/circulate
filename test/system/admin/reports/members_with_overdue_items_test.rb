require "application_system_test_case"

class AdminMembersWithOverdueItemsTest < ApplicationSystemTestCase
  include AdminHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::NumberHelper
  include MembersHelper

  setup do
    sign_in_as_admin

    @member_without_loans = create(:member, :with_user, preferred_name: "Loanless Lane")

    @member_with_non_overdue_loans = create(:member, :with_user, preferred_name: "Mr. Ontime")
    create(:loan, member: @member_with_non_overdue_loans)
    create(:ended_loan, member: @member_with_non_overdue_loans)

    @member_with_one_overdue_loan = create(:member, :with_user, preferred_name: "(Over)Drew")
    create(:overdue_loan, member: @member_with_one_overdue_loan, due_at: 3.weeks.ago)
    create(:loan, member: @member_with_one_overdue_loan)

    @member_with_multiple_overdue_loans = create(:member, :with_user, preferred_name: "(Mul)Timothy")
    1.upto(3).each do |n|
      create(:overdue_loan, member: @member_with_multiple_overdue_loans, due_at: n.weeks.ago)
    end
    create(:loan, member: @member_with_multiple_overdue_loans)
    create(:ended_loan, member: @member_with_multiple_overdue_loans)

    @overdue_loan_members = [@member_with_one_overdue_loan, @member_with_multiple_overdue_loans]
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
        assert_text time_ago_in_words(loan.due_at)
      end
    end
    assert_equal 3, all("tr").size # 2 for members, 1 for the header
  end

  test "the table can be filtered by borrow policy" do
    borrow_policy_1, borrow_policy_2 = BorrowPolicy.first(2)
    Item.update_all(borrow_policy_id: borrow_policy_1.id)
    @member_with_one_overdue_loan.overdue_loans.each do |loan|
      loan.item.update!(borrow_policy: borrow_policy_2)
    end
    BorrowPolicy.where.not(id: [borrow_policy_1, borrow_policy_2].map(&:id)).delete_all

    visit admin_reports_members_with_overdue_loans_url

    assert_text @member_with_one_overdue_loan.user.email
    assert_text @member_with_multiple_overdue_loans.user.email

    assert_text borrow_policy_1.name
    assert_text borrow_policy_2.name

    click_on borrow_policy_2.name

    assert_text @member_with_one_overdue_loan.user.email
    refute_text @member_with_multiple_overdue_loans.user.email

    click_on "All"

    assert_text @member_with_one_overdue_loan.user.email
    assert_text @member_with_multiple_overdue_loans.user.email
  end
end
