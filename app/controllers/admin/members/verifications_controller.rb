# frozen_string_literal: true

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
          name = if @member.preferred_name.blank?
            @member.full_name
          else
            @member.preferred_name
          end
          flash[:success] = "#{name}'s membership has been activated."
          redirect_to admin_member_url(@member)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private
        def load_member
          super
          if @member.status_verified?
            redirect_to admin_members_path, warning: "Member is already verified."
          end
        end

        def verification_params
          params.require(:admin_verification).permit(:id_kind, :other_id_kind, :address_verified)
        end
    end
  end
end
