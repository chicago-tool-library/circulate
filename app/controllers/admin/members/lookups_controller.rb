module Admin
  module Members
    class LookupsController < BaseController
      def show
        @member = Member.find(params[:member_id])
        @lookup = Lookup.new(lookup_params)

        if @lookup.valid?
          @loan = Loan.lend(@lookup.item, to: @member)
          @item = @lookup.item
        else
          render partial: "admin/members/lookups/form", status: :unprocessable_entity, locals: {lookup: @lookup}
        end
      end

      def lookup_params
        params.require(:admin_lookup).permit(:item_number)
      end
    end
  end
end
