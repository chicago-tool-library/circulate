module Signup
  module Organizations
    class ProfilesController < BaseController
      def show
        activate_step(:profile)
        @organization_member_signup_form = OrganizationMemberSignupForm.new
      end

      def update
        @organization_member_signup_form = OrganizationMemberSignupForm.new(organization_member_signup_form_params)

        if @organization_member_signup_form.save
          session[:email_address] = @organization_member_signup_form.user.email
          redirect_to signup_organizations_confirm_email_url
        else
          activate_step(:profile)
          render :show, status: :unprocessable_entity
        end
      end

      private

      def organization_member_signup_form_params
        params.require(:organization_member_signup_form).permit(
          :full_name, :email, :password, :password_confirmation, :name, :website
        )
      end
    end
  end
end
