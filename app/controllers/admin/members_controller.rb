module Admin
  class MembersController < BaseController
    include Pagy::Backend

    include MemberOrdering

    before_action :set_member, only: [:show, :edit, :update, :destroy]

    def index
      member_scope = params[:filter] == "closed" ? Member.closed : Member.open
      @pagy, @members = pagy(
        member_scope.order(index_order).includes([:active_membership, :checked_out_loans, :active_holds]),
        items: 100
      )
    end

    def show
      @new_item_numbers = []
      @new_loans = {}

      @returned_loan_summaries = @member.loan_summaries.returned_since(Time.current.beginning_of_day).includes(:latest_loan, item: :borrow_policy).by_end_date
      @active_loan_summaries = @member.loan_summaries.checked_out.includes(:latest_loan, item: :borrow_policy).by_due_date

      @check_out = CheckOut.new

      @item_name = params[:item_name]
      if @item_name
        @items_by_name = Item.name_contains(@item_name).by_name
      end
    end

    def new
      @member = Member.new
    end

    def edit
    end

    def create
      @member = Member.new(member_params)

      respond_to do |format|
        if @member.save
          format.html { redirect_to [:admin, @member], notice: "Member was successfully created." }
          format.json { render :show, status: :created, location: @member }
        else
          format.html { render :new }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @member.update(member_params)
          format.html { redirect_to [:admin, @member], notice: "Member was successfully updated." }
          format.json { render :show, status: :ok, location: @member }
        else
          format.html { render :edit }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @member.destroy
      respond_to do |format|
        format.html { redirect_to admin_members_url, notice: "Member was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(
        :full_name, :preferred_name, :email, :phone_number, :postal_code,
        :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter, :volunteer_interest,
        :notes, :status, :address1, :address2, pronouns: []
      )
    end
  end
end
