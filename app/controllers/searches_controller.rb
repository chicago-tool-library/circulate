class SearchesController < ApplicationController
  def create
    query = params[:query]
    
    item = Item.where(number: query).first
    redirect_to item_path(item) and return if item

    member = Member.matching(query).first
    redirect_to member_path(member) and return if member

    redirect_to search_path
  end

  def show
    
  end
end