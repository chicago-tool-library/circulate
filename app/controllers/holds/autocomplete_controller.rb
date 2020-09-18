module Holds
  class AutocompleteController < BaseController
    layout false

    def index
      query = params[:query]
      @items = Item.active.search_by_anything(query).by_name.includes(:borrow_policy, :checked_out_exclusive_loan, :active_holds, image_attachment: :blob)
    end
  end
end
