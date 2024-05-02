module Admin
  module Items
    class LoanHistoriesController < BaseController
      def show
        @item = Item.find(params[:item_id])
        @loans = @item.loans.includes(:member).order(created_at: :desc)
      end
    end
  end
end
