module Admin
  class MembersController < BaseController
    include Pagy::Backend

    include MemberOrdering

    before_action :set_member, only: [:show, :edit, :update, :destroy, :resend_verification_email]

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

      Member.transaction do
        user = User.new(
          email: @member.email,
          password: Devise.friendly_token,
          role: :member
        )
        user.skip_confirmation!  # Admin-created users are pre-verified
        @member.user = user

        if @member.save && user.save
          user.send_reset_password_instructions
          redirect_to [:admin, @member], success: "Member was successfully created. A password reset email has been sent.", status: :see_other
        else
          raise ActiveRecord::Rollback
        end
      end || render(:new, status: :unprocessable_content)
    end

    def update
      if @member.update(member_params)
        redirect_to [:admin, @member], success: "Member was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_content
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
