module Admin
  module Members
    class PasswordsController < BaseController
      def edit
        @user = @member.user
        @user.password = User.generate_temporary_password
      end

      def update
        @user = @member.user

        if @user.update(user_params)
          MemberMailer.with(member: @member, new_password: @user.password).admin_reset_password.deliver_now
          redirect_to admin_member_url(@member), success: "Successfully reset member's password"
        else
          render :edit, status: 422
        end
      end

      private

      def user_params
        params.require(:user).permit(:password)
      end
    end
  end
end
