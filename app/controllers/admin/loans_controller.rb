module Admin
  class LoansController < BaseController
    before_action :set_loan, only: [:show, :edit, :update, :destroy]

    # GET /loans
    # GET /loans.json
    def index
      @loans = Loan.includes(:member, :item).all
    end

    # GET /loans/1
    # GET /loans/1.json
    def show
    end

    # GET /loans/new
    def new
      @loan = Loan.new
    end

    # GET /loans/1/edit
    def edit
    end

    # POST /loans
    # POST /loans.json
    def create
      @item = Item.where(number: new_loan_params[:item_number]).first
      due_at = item_id = nil
      if @item
        due_at = Time.zone.today.end_of_day + @item.borrow_policy.duration.days
        item_id = @item.id
      end
      @loan = Loan.new(member_id: new_loan_params[:member_id], item_id: item_id, due_at: due_at, uniquely_numbered: @item&.borrow_policy&.uniquely_numbered)

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

    # PATCH/PUT /loans/1
    # PATCH/PUT /loans/1.json
    def update
      respond_to do |format|
        ended_at = update_loan_params[:ended] == "1" ? Time.current : nil

        if @loan.update(ended_at: ended_at)

          if @loan.ended_at
            policy = @loan.item.borrow_policy
            amount = FineCalculator.new.amount(fine: policy.fine, period: policy.fine_period, due_at: @loan.due_at, returned_at: @loan.ended_at)
            if amount > 0
              Adjustment.create!(member_id: @loan.member_id, adjustable: @loan, amount: amount * -1, kind: Adjustment.kinds[:fine])
            end
          end

          format.html { redirect_to admin_member_path(@loan.member, anchor: "checkout"), notice: "Loan was successfully updated." }
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

    # DELETE /loans/1
    # DELETE /loans/1.json
    def destroy
      @loan.destroy
      respond_to do |format|
        format.html { redirect_to admin_loans_url, notice: "Loan was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_loan
      @loan = Loan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def new_loan_params
      params.require(:loan).permit(:item_number, :member_id)
    end

    def update_loan_params
      params.require(:loan).permit(:ended)
    end
  end
end
