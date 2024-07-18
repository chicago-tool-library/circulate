module Admin
  class SearchesController < BaseController
    def create
      query = params[:query]

      redirect_to admin_search_path(query: query), status: :see_other
    end

    def show
      @query = params[:query]
      @exact = params[:exact] != "false"

      @member_by_number = Member.find_by(number: @query)
      @item_by_number = Item.find_by(number: @query)

      if !@member_by_number && !@item_by_number
        @exact = false
      end

      if !@exact && @query.size >= 2
        @items = search_items
        @members = Member.matching(@query).open.by_full_name
      end
    end

    private

    def search_items
      query = Item.search_by_anything(@query).by_name
      query = query.available_now if params[:available].present?
      query
    end
  end
end
