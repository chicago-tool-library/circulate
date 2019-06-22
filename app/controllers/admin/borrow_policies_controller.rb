module Admin
  class BorrowPoliciesController < BaseController
    before_action :set_borrow_policy, only: [:show, :edit, :update, :destroy]

    # GET /borrow_policies
    # GET /borrow_policies.json
    def index
      @borrow_policies = BorrowPolicy.all
    end

    # GET /borrow_policies/1
    # GET /borrow_policies/1.json
    def show
    end

    # GET /borrow_policies/new
    def new
      @borrow_policy = BorrowPolicy.new
    end

    # GET /borrow_policies/1/edit
    def edit
    end

    # POST /borrow_policies
    # POST /borrow_policies.json
    def create
      @borrow_policy = BorrowPolicy.new(borrow_policy_params)

      respond_to do |format|
        if @borrow_policy.save
          format.html { redirect_to [:admin, @borrow_policy], notice: "Borrow policy was successfully created." }
          format.json { render :show, status: :created, location: [:admin, @borrow_policy] }
        else
          format.html { render :new }
          format.json { render json: @borrow_policy.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /borrow_policies/1
    # PATCH/PUT /borrow_policies/1.json
    def update
      respond_to do |format|
        if @borrow_policy.update(borrow_policy_params)
          format.html { redirect_to [:admin, @borrow_policy], notice: "Borrow policy was successfully updated." }
          format.json { render :show, status: :ok, location: [:admin, @borrow_policy] }
        else
          format.html { render :edit }
          format.json { render json: @borrow_policy.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /borrow_policies/1
    # DELETE /borrow_policies/1.json
    def destroy
      @borrow_policy.destroy
      respond_to do |format|
        format.html { redirect_to admin_borrow_policies_url, notice: "Borrow policy was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_borrow_policy
      @borrow_policy = BorrowPolicy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def borrow_policy_params
      params.require(:borrow_policy).permit(:name, :duration, :fine, :fine_period)
    end
  end
end
