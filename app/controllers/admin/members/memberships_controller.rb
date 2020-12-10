module Admin
  module Members
    class MembershipsController < BaseController
      def index
        @memberships = @member.memberships
      end

      def new
        @form = MembershipForm.new(@member)
      end

      def create
        @form = MembershipForm.new(@member, membership_form_params)
        if @form.save
          redirect_to admin_member_path(@member), success: "Membership created."
        else
          render :new
        end
      end

      # This should probably be a MembershipActivation controller since it doesn't rely on params.
      def update
        @membership = @member.pending_membership

        if @membership
          @membership.start!
          redirect_to admin_member_path(@member), success: "Membership started."
        else
          redirect_to admin_member_path(@member), error: "Could not start membership"
        end
      end

      private

      def membership_form_params
        params.require(:membership_form).permit(:amount_dollars, :payment_source, :with_payment, :start_membership)
      end
    end
  end
end
