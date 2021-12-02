module Admin
  class LoansController < BaseController
    include ActionView::RecordIdentifier
    include Lending

    def index
      scope = if params[:member_id]
        Member.find(params[:member_id]).loans
      else
        Loan
      end
      @loans = scope.includes(:member, :item).all
    end

    def create
      @item = Item.find(new_loan_params[:item_id])
      @member = Member.find(new_loan_params[:member_id])

      @loan = Loan.lend(@item, to: @member)

      if @loan.save
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@loan))
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout")
      end
    end

    def update
      @loan = Loan.find(params[:id])

      success = if update_loan_params[:ended] == "1"
        return_loan(@loan)
      else
        restore_loan(@loan)
      end

      if success
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@loan))
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout")
      end
    end

    def destroy
      @loan = Loan.find(params[:id])

      if !@loan.renewal? && @loan.destroy
        redirect_to admin_member_path(@loan.member)
      else
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), error: "Loan could not be destroyed!"
      end
    end

    private

    def new_loan_params
      params.require(:loan).permit(:item_id, :member_id)
    end

    def update_loan_params
      params.require(:loan).permit(:ended)
    end
  end
end
