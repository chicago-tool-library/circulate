# frozen_string_literal: true

module Admin
  class LoanHistoriesController < BaseController
    def show
      scope = if params[:member_id]
        Member.find(params[:member_id]).loans
      elsif params[:item_id]
        Item.find(params[:item_id]).loan_summaries
      else
        Loan
      end
      @loans = scope.includes(:member, item: :borrow_policy).order(created_at: "desc").all
    end
  end
end
