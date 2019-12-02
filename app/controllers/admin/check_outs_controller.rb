module Admin
  class CheckOutsController < BaseController
    include MemberPage
    include PortalRendering

    def create
      @member = Member.find(params[:member_id])
      @check_out = CheckOut.new(check_out_params.merge(member: @member))

      if @check_out.valid?
        render_to_portal "admin/loans/form"
      else
        render_to_portal "admin/check_outs/form", status: 422
      end
    end

    def check_out_params
      params.require(:admin_check_out).permit(:item_number)
    end
  end
end
