module Admin
  module Members
    class LookupsController < BaseController
      include PortalRendering

      def create
        @member = Member.find(params[:member_id])
        @check_out = CheckOut.new(check_out_params.merge(member: @member))

        if @check_out.valid?
          @item = @check_out.item
          @loan = Loan.lend(@item, to: @member)
          render_to_portal "admin/members/lookups/create"
        else
          render_to_portal "admin/members/lookups/form", status: 422
        end
      end

      def check_out_params
        params.require(:admin_check_out).permit(:item_number)
      end
    end
  end
end
