module Admin
  class LookupsController < BaseController
    include PortalRendering

    def create
      @member = Member.find(params[:member_id])
      @lookup = Lookup.new(lookup_params)

      puts "dupa"
      puts params
      puts lookup_params

      if @lookup.valid?
        # @loan = Loan.lend(@lookup.item, to: @member)
        @items = @lookup.item_name_or_number
        render_to_portal "admin/lookups/results"
      else
        render_to_portal "admin/lookups/form", status: 422, locals: {lookup: @lookup}
      end
    end

    def lookup_params
      params.require(:admin_lookup).permit(:item_name_or_number)
    end
  end
end
