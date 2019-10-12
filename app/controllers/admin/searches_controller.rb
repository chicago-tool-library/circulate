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
      query = params[:query]
      @items = Item.search_by_anything(query).by_name
      @items_by_number = Item.number_contains(query)
      @members = Member.matching(query).by_full_name
    end
  end
end
