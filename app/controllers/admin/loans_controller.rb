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

      respond_to do |format|
        if @loan.save
          format.html { redirect_to admin_member_path(@loan.member, anchor: "checkout"), notice: "Loan was successfully created." }
          format.json { render :show, status: :created, location: @loan }
        else
          format.html do
            flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
            redirect_to admin_member_path(@loan.member, anchor: "checkout")
          end
          format.json { render json: @loan.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        ended_at = update_loan_params[:ended] == "1" ? Time.current : nil

        if @loan.update(ended_at: ended_at)

          if @loan.ended_at
            policy = @loan.item.borrow_policy
            amount = FineCalculator.new.amount(fine: policy.fine, period: policy.fine_period, due_at: @loan.due_at, returned_at: @loan.ended_at)
            if amount > 0
              Adjustment.create!(member_id: @loan.member_id, adjustable: @loan, amount: amount * -1, kind: "fine")
            end
          end

          format.html { redirect_to admin_member_path(@loan.member, anchor: "checkout"), success: "Loan was successfully updated." }
          format.json { render :show, status: :ok, location: @loan }
        else
          format.html do
            flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
            redirect_to admin_member_path(@loan.member, anchor: "checkout")
          end
          format.json { render json: @loan.errors, status: :unprocessable_entity }
        end
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