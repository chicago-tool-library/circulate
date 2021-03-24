class SearchesController < ApplicationController
  def show
    query = params[:query].to_s.strip

    if query.size < 3
      @items = []
      @items_by_number = []
      flash.now[:warning] = "You must provide at least three numbers or letters to search by."
    else
      @items = Item.search_by_anything(query).by_name
      @items_by_number = Item.number_contains(query)
    end
  end
end
