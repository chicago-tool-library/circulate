class MemberProfiles::PasswordsController < ApplicationController
  def edit
    @member = current_user.member
  end
end
