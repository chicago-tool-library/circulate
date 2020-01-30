module Admin
  class LoansController < BaseController
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
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), success: "Loan was successfully created."
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout")
      end
    end

    def update
      @loan = Loan.find(params[:id])
      ended_at = update_loan_params[:ended] == "1" ? Time.current : nil

      if @loan.update(ended_at: ended_at)
        if @loan.ended_at
          policy = @loan.item.borrow_policy
          amount = FineCalculator.new.amount(fine: policy.fine, period: policy.fine_period, due_at: @loan.due_at, returned_at: @loan.ended_at)
          if amount > 0
            Adjustment.create!(member_id: @loan.member_id, adjustable: @loan, amount: amount * -1, kind: "fine")
          end
        end
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), success: "Loan was successfully updated."
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout")
      end
    end

    def destroy
      @loan = Loan.find(params[:id])

      if !@loan.renewal? && @loan.destroy
        message = "The loan was removed."
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), success: message
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
