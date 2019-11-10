module Admin
  class CheckOutsController < BaseController
    include MemberPage
    layout nil

    def create
      @member = Member.find(params[:member_id])
      @check_out = CheckOut.new(check_out_params.merge(member: @member))

      if @check_out.valid?
        render partial: "admin/loans/form", turbolinks: false
      else
        render partial: "admin/check_outs/form", turbolinks: false, status: 422
      end
    end

    def check_out_params
      params.require(:admin_check_out).permit(:item_number)
    end
  end
end
