# frozen_string_literal: true

module Admin
  class ItemHistoriesController < BaseController
    def show
      @item = Item.find(params[:item_id])
      @audits = @item.audits.includes(:user)
    end
  end
end
