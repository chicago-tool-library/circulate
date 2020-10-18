class MembersController < ApplicationController

  before_action :authenticate_user!

  def renew
    @loan = Loan.find(params[:id])
    authorize @loan, :renew?

    @loan.renew!
    redirect_to account_home_path
  end
end
