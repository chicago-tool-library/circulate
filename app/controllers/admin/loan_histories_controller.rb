module Admin
  class LoanHistoriesController < BaseController
    def show
      scope = if params[:member_id]
        Member.find(params[:member_id]).loans
      elsif params[:item_id]
        Item.find(params[:item_id]).loans
      else
        Loan
      end
      @loans = scope.includes(:member, item: :borrow_policy).all
    end
  end
end
