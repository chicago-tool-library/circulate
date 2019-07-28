module Admin
  class ImagesController < BaseController

    def show
      @item = Item.find(params[:item_id])
      @image = @item.image
    end

    def update
      @item = Item.find(params[:item_id])
      @image = @item.image

      @image.metadata["rotation"] = image_params[:rotation]
      @image.attachment.blob.save!

      redirect_to admin_item_url(@item)
    end

    private

    def image_params
      params.require(:image).permit(:rotation)
    end
  end
end