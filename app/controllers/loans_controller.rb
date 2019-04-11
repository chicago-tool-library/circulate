class LoansController < ApplicationController
  before_action :set_loan, only: [:show, :edit, :update, :destroy]

  # GET /loans
  # GET /loans.json
  def index
    @loans = Loan.all
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
    item_id = Item.where(number: new_loan_params[:item_number]).pluck(:id).first
    @loan = Loan.new(member_id: new_loan_params[:member_id], item_id: item_id, due_at: Date.today.end_of_day + 7.days)

    respond_to do |format|
      if @loan.save
        format.html { redirect_to @loan.member, notice: 'Loan was successfully created.' }
        format.json { render :show, status: :created, location: @loan }
      else
        format.html do
          flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
          redirect_to @loan.member
        end
        format.json { render json: @loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loans/1
  # PATCH/PUT /loans/1.json
  def update
    respond_to do |format|
      ended_at = update_loan_params[:ended] == "1" ? Time.now : nil

      if @loan.update(ended_at: ended_at)
        format.html { redirect_to @loan.member, notice: 'Loan was successfully updated.' }
        format.json { render :show, status: :ok, location: @loan }
      else
        format.html do
          flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
          redirect_to @loan.member
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
      format.html { redirect_to loans_url, notice: 'Loan was successfully destroyed.' }
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
