module Account
  class MembersController < ApplicationController
    
    def show
      @member = current_member
    end

    def edit
    end

    def update
      respond_to do |format|
        if current_member.update(member_params)
          format.html { redirect_to account_member_url, success: "Profile was successfully updated." }
          format.json { render :show, status: :ok, location: current_member }
        else
          format.html { render :edit }
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