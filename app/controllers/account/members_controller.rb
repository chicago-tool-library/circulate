module Account
  class MembersController < BaseController
    before_action :load_member

    def show
      @summaries = @member.loan_summaries
        .active_on(Time.current)
        .or(@member.loan_summaries.checked_out)
        .includes(item: :borrow_policy)
        .by_due_date
      @has_overdue_items = @summaries.any? { |s| s.overdue_as_of?(Time.current.beginning_of_day.tomorrow) }
    end

    private

    def load_member
      load_member_from_encrypted_id(params[:id])
    end
  end
end
