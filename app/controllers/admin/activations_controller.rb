module Admin
  class ActivationsController < BaseController
    before_action :load_member

    def edit
      @activation = Activation.new(@member.attributes.slice("id_kind", "id_kind_other", "address_verified"))
    end

    def update
      @activation = Activation.new(activation_params)
      if @activation.valid?
        @activation.copy_to(@member)
        @member.status_active!
        flash[:success] = "#{@member.preferred_name}'s membership has been activated."
        redirect_to admin_member_url(@member)
      else
        render :edit
      end
    end

    private

    def load_member
      @member = Member.find(params[:member_id])
      if @member.status_active?
        redirect_to admin_members_path, warning: "Member is already active."
      end
    end

    def activation_params
      params.require(:admin_activation).permit(:id_kind, :other_id_kind, :address_verified)
    end
  end
end
