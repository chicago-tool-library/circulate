module Admin
  class MembersController < BaseController
    include Pagy::Backend

    include MemberOrdering
    include Flagging

    before_action :set_member, only: [:show, :edit, :update, :destroy, :resend_verification_email, :flag]

    def index
      member_scope = (params[:filter] == "closed") ? Member.closed : Member.open
      @pagy, @members = pagy(
        member_scope.order(index_order).includes(:active_membership, :last_membership, :checked_out_loans, :active_holds),
        items: 100
      )
    end

    def show
      @new_item_numbers = []
      @new_loans = {}

      @returned_loan_summaries = @member.loan_summaries.returned_since(Time.current.beginning_of_day).includes(:latest_loan, item: :borrow_policy).by_end_date
      @active_loan_summaries = @member.loan_summaries.checked_out.includes(:latest_loan, item: :borrow_policy).by_due_date

      @check_out = CheckOut.new
    end

    def new
      @member = Member.new
    end

    def edit
    end

    def create
      @member = Member.new(member_params)

      if @member.save
        redirect_to [:admin, @member], success: "Member was successfully created.", status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @member.update(member_params)
        redirect_to [:admin, @member], success: "Member was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @member.destroy
        redirect_to admin_members_url, success: "Member was successfully destroyed.", status: :see_other
      else
        redirect_to admin_member_url(@member), error: "Member could not be destroyed.", status: :see_other
      end
    end

    def resend_verification_email
      @member.user.send_confirmation_instructions
      email = @member.user.unconfirmed_email || @member.user.email

      redirect_to admin_member_url(@member), success: "Verification email sent to #{email}", status: :see_other
    end

    def flag
      if @member.flagged?
        unflag_obj(@member)
      else
        flag_obj(@member)
      end
      redirect_to admin_members_path, status: :see_other
    end

    private

    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      params.require(:member).permit(
        :full_name, :pronunciation, :preferred_name, :email, :phone_number, :postal_code,
        :desires, :reminders_via_email, :reminders_via_text, :receive_newsletter, :volunteer_interest, :bio,
        :status, :address1, :address2, pronouns: []
      )
    end
  end
end
