module Admin
  class DashboardController < BaseController
    def index
      # totals
      @items_on_loan = Loan.checked_out.count
      @overdue_loans = LoanSummary.overdue
        .joins(:member)
        .merge(Member.verified)
        .count
      @total_members = Member.open.count
      @total_verified_members = Member.verified.count
      @total_items = Item.active.count

      # today
      @appointments_today = Appointment.where("DATE(starts_at) = ?", Time.zone.today).count
      @items_checked_out_today = Loan.where("created_at BETWEEN ? AND ?", Time.current.beginning_of_day, Time.current.end_of_day).count

      # this week
      @loans_past_week = Loan.where("created_at >= ?", 7.days.ago).count
      @new_members_past_week = Member.where("created_at >= ?", 7.days.ago).count
      @new_verified_members_past_week = Member.verified.where("created_at >= ?", 7.days.ago).count
    end
  end
end
