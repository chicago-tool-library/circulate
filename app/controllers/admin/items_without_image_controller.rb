module Admin
  class ItemsWithoutImageController < BaseController
  	def index
  	  @items = Item.without_attached_image
    end
  end
end
