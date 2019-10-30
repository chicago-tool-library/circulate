class SearchesController < ApplicationController
  def show
    query = params[:query]
    @items = Item.search_by_anything(query).by_name
    @items_by_number = Item.number_contains(query)
  end
end
