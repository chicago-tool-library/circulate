class MembersController < ApplicationController
  def loans
    @loans = current_user.loans.includes(:item).order(:due_at)
  end

  # Temporarily overriding devise method for testing purposes
  def current_user
    Member.first
  end
end
