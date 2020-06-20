class AutocompleteController < ApplicationController
  layout false

  def index
    query = params[:query]
    @items = Item.search_by_anything(query).by_name
  end
end
