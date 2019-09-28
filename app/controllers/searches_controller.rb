class SearchesController < ApplicationController
  def show
    @items = Item.search_by_anything(params[:query]).order("items.name ASC")
    render :show
  end
end