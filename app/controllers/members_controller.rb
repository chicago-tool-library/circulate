class MembersController < ApplicationController
  def loans
    @loans = current_member.loans.includes(:item).order(:due_at)
  end
end
