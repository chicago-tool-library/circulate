module Admin
  class VerificationsController < BaseController
    before_action :load_member

    def edit
      @verification = Verification.new(@member.attributes.slice("id_kind", "id_kind_other", "address_verified"))
    end

    def update
      @verification = Verification.new(verification_params)
      if @verification.valid?
        @verification.copy_to(@member)
        @member.status_verified!
        flash[:success] = "#{@member.preferred_name}'s membership has been activated."
        redirect_to admin_member_url(@member)
      else
        render :edit
      end
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
      if @member.status_verified?
        redirect_to admin_members_path, warning: "Member is already verified."
      end
    end

    def verification_params
      params.require(:admin_verification).permit(:id_kind, :other_id_kind, :address_verified)
    end
  end
end
