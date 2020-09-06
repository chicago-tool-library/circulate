class MembersController < ApplicationController
  def history
    @loans = current_user.loans
  end

  private

  # temporary until we have the member login completed
  def current_user
    Member.first
  end
end
