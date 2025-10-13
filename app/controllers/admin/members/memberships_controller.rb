module Admin
  module Members
    class MembershipsController < BaseController
      def index
        @memberships = @member.memberships.order(created_at: :desc)
        @adjustments = @member.adjustments.order(created_at: :desc)
      end

      def new
        @form = MembershipForm.new(@member)
      end

      def create
        @form = MembershipForm.new(@member, membership_form_params)
        if @form.save
          redirect_to admin_member_memberships_path(@member), success: "Membership created.", status: :see_other
        else
          render :new, status: :unprocessable_content
        end
      end

      # This should probably be a MembershipActivation controller since it doesn't rely on params.
      def update
        @membership = @member.pending_membership

        if @membership
          @membership.start!
          redirect_to admin_member_memberships_path(@member), success: "Membership started.", status: :see_other
        else
          redirect_to admin_member_path(@member), error: "Could not start membership", status: :see_other
        end
      end

      private

      def membership_form_params
        params.require(:membership_form).permit(:amount_dollars, :payment_source, :with_payment, :start_membership)
      end
    end
  end
end
