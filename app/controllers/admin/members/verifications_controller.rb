module Admin
  module Members
    class VerificationsController < BaseController
      def edit
        @verification = Verification.new(@member.attributes.slice("id_kind", "id_kind_other", "address_verified"))
      end

      def update
        @verification = Verification.new(verification_params)
        if @verification.valid?
          @member.transaction do
            @verification.copy_to(@member)
            @member.assign_number
            @member.status_verified!
          end
          name = @member.preferred_name.presence || @member.full_name
          flash[:success] = "#{name}'s membership has been activated."
          redirect_to admin_member_url(@member), status: :see_other
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def load_member
        super
        if @member.status_verified?
          redirect_to admin_members_path, warning: "Member is already verified.", status: :see_other
        end
      end

      def verification_params
        params.require(:admin_verification).permit(:id_kind, :other_id_kind, :address_verified)
      end
    end
  end
end
