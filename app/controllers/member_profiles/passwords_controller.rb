class MemberProfiles::PasswordsController < ApplicationController

  before_action :authenticate_user!
  
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to account_member_url, success: "Your password has been updated."
    else
      redirect_to edit_member_profiles_password_url, warning: @user.errors.full_messages.join(". ").to_s
    end
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
