class MembersController < ApplicationController
  def history
    @loans = current_member.loans.order(ended_at: :desc)
    # This could be appended to only show items that have been checked in
    # if it's decided this page shouldn't show currently checked-out items:
    # .where.not(loans: { ended_at: nil })
  end

  def loans
    @loans = current_member.loans.includes(:item).order(:due_at)
  end
end
