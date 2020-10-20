module Admin
  class LookupsController < BaseController
    include PortalRendering

    def create
      @member = Member.find(params[:member_id])
      @lookup = Lookup.new(lookup_params)

      # puts lookup_params

      if @lookup.valid?
        @loan = Loan.lend(@lookup.item, to: @member)
        @item = @lookup.item
        render_to_portal "admin/lookups/create"
      else
        render_to_portal "admin/lookups/form", status: 422, locals: {lookup: @lookup}
      end
    end

    # def name_create
    #   @member = Member.find(params[:member_id])
    #   @lookup = Lookup.new(lookup_params)

    #   if @lookup.valid?
    #     @loan = Loan.lend(@lookup.item, to: @member)
    #     @item = @lookup.item
    #     render_to_portal "admin/lookups/create"
    #   else
    #     render_to_portal "admin/lookups/form", status: 422, locals: {lookup: @lookup}
    #   end
    # end

    def lookup_params
      # params.require(:admin_lookup).permit(:item_number, :item_name)
      params.require(:admin_lookup).permit(:item_number)
    end
  end
end
