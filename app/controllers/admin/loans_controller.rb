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

      over_ready_hold = params[:over_ready_hold] == "1" && current_user.has_role?(:admin)
      @loan = lend_to_member(@item, @member, over_ready_hold:)

      if @loan.persisted?
        flash_highlight(@loan)
        flash[:warning] = hold_returned_to_line_reminder if @hold_returned_to_line
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@loan)), status: :see_other
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), status: :see_other
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
        redirect_to admin_member_path(@loan.member, anchor: dom_id(@loan)), status: :see_other
      else
        flash[:checkout_error] = @loan.errors.full_messages_for(:item_id).join
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), status: :see_other
      end
    end

    def destroy
      @loan = Loan.find(params[:id])

      if undo_loan(@loan)
        redirect_to admin_member_path(@loan.member), status: :see_other
      else
        redirect_to admin_member_path(@loan.member, anchor: "checkout"), error: "Loan could not be undone!", status: :see_other
      end
    end

    private

    # Circulate doesn't notify a member whose ready hold is lent out from
    # under them; staff reach out personally instead, so tell them what to say.
    def hold_returned_to_line_reminder
      hold, starts_at, change = @hold_returned_to_line.values_at(:hold, :appointment_starts_at, :appointment_change)
      member = hold.member
      message = "#{hold.item.complete_number} was ready for #{helpers.preferred_or_default_name(member)} (##{member.number}). " \
        "Their hold is waiting again, still in the same place in line. They haven't been notified, so please reach out to them."
      if change
        when_text = starts_at.in_time_zone("America/Chicago").strftime("%A, %B %-d at %-I:%M%P")
        message += (change == :cancelled) ?
          " Their appointment on #{when_text} was cancelled, since nothing else was on it." :
          " It was taken off their appointment on #{when_text}."
      end
      message
    end

    def new_loan_params
      params.require(:loan).permit(:item_id, :member_id)
    end

    def update_loan_params
      params.require(:loan).permit(:ended)
    end
  end
end
