module Admin
  class SearchesController < BaseController
    def create
      query = params[:query]

      item = Item.where(number: query).first
      redirect_to(admin_item_path(item)) && return if item

      member = Member.matching(query).first
      redirect_to(admin_member_path(member)) && return if member

      redirect_to admin_search_path(query: params[:query])
    end

    def show
      @items = Item.search_by_anything(params[:query]).order("items.name ASC")
    end
  end
end
