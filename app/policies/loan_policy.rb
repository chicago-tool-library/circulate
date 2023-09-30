# frozen_string_literal: true

class LoanPolicy
  attr_reader :user, :loan

  def initialize(user, loan)
    @user = user
    @loan = loan
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def renew?
    if user.admin?
      loan.renewable?
    else
      user.member == loan.member && loan.member_renewable?
    end
  end
end
