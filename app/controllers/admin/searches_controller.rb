module Admin
  class SearchesController < BaseController
    def create
      query = params[:query]

      # item = Item.where(number: query).first
      # redirect_to(admin_item_path(item)) && return if item

      # member = Member.matching(query).first
      # redirect_to(admin_member_path(member)) && return if member

      redirect_to admin_search_path(query: query)
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
        # @items_by_number = Item.number_contains(query)
        @items = Item.search_by_anything(@query).by_name
        @members = Member.matching(@query).open.by_full_name
      end
    end

    def name_search
      @query = params[:query]
      @items_by_name = Item.name_contains(@query).by_name

      redirect_to admin_search_path(query: @query)
    end

    def name_or_number_search
      @query = params[:query]
      @items_by_name_or_number = Item.name_or_number_contains(@query).by_name

      redirect_to admin_search_path(query: @query)
    end
  end
end
