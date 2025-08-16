module Account
  class MembersController < BaseController
    def show
      @member = current_member
      load_borrow_policies_and_approvals
    end

    def agreement
      @document = Document.where(code: "agreement").last
    end

    def code_of_conduct
      @document = Document.where(code: "code_of_conduct").last
    end

    def borrow_policy
      @document = Document.where(code: "borrow_policy").last
    end

    def edit
    end

    def update
      respond_to do |format|
        if current_member.update(member_params)
          if current_member.saved_change_to_email?
            current_member.user.send_confirmation_instructions
          end

          format.html { redirect_to account_member_url, success: "Profile was successfully updated.", status: :see_other }
          format.json { render :show, status: :ok, location: current_member }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def member_params
      params.require(:member).permit(:full_name,
        :preferred_name,
        :email,
        :phone_number,
        :address1,
        :address2,
        :postal_code,
        :desires,
        :reminders_via_email,
        :reminders_via_text,
        :receive_newsletter,
        :volunteer_interest,
        pronouns: [])
    end

    def load_borrow_policies_and_approvals
      @borrow_policies_and_approvals ||= begin
        borrow_policies = BorrowPolicy.where(requires_approval: true).order(:code)
        borrow_policy_approvals = current_member.borrow_policy_approvals

        borrow_policy_approvals_by_borrow_policy_id = borrow_policy_approvals.each_with_object({}) do |approval, approvals|
          approvals[approval.borrow_policy_id] = approval
        end

        borrow_policies.each_with_object({}) do |borrow_policy, borrow_policies_and_approvals|
          borrow_policies_and_approvals[borrow_policy] = borrow_policy_approvals_by_borrow_policy_id[borrow_policy.id]
        end
      end
    end
  end
end
