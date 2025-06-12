module Account
  class MembersController < BaseController
    def show
      @member = current_member
    end

    def agreement
      @document = Document.where(code: 'agreement').last
    end

    def code_of_conduct
      @document = Document.where(code: 'code_of_conduct').last
    end
    
    def borrow_policy
      @document = Document.where(code: 'borrow_policy').last
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
  end
end
