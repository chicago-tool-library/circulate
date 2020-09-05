class MembersController < ApplicationController
  def loans
    @loans = current_user.loans
  end

  # Temporarily overriding devise method for testing purposes
  def current_user
    Member.first
  end
end
