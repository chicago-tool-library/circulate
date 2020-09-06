class MembersController < ApplicationController
  def history
    @loans = current_user.loans.order(ended_at: :desc)
    # This could be appended to only show items that have been checked in
    # if it's decided this page shouldn't show currently checked-out items:
    # .where.not(loans: { ended_at: nil })
  end

  private

  # temporary until we have the member login completed
  def current_user
    Member.first
  end
end
