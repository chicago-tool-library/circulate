module Admin
  class RenewalsController < BaseController
    def create
      @loan = Loan.find(params[:loan_id])

      @loan.transaction do
        now = Time.current
        @loan.update!(ended_at: now)
        Loan.create!(
          member_id: @loan.member_id,
          item_id: @loan.item_id,
          initial_loan_id: @loan.id,
          created_at: now,
          renewal_count: @loan.renewal_count + 1,
          due_at: Time.zone.today.end_of_day + @loan.item.borrow_policy.duration.days,
          uniquely_numbered: @loan.uniquely_numbered,
        )
      end

      redirect_to admin_member_url(@loan.member_id, anchor: "checkout")
    end
  end
end
