# frozen_string_literal: true

module Admin
  class ImagesController < BaseController
    before_action :load_image

    def edit
    end

    def update
      @image.metadata["rotation"] = image_params[:rotation]
      @image.attachment.blob.save!

      redirect_to admin_item_url(@item)
    end

    private
      def image_params
        params.require(:image).permit(:rotation)
      end

      def load_image
        @item = Item.find(params[:item_id])
        unless @item.image.attached?
          redirect_to admin_item_path(@item), error: "Image not found"
        end
        @image = @item.image
      end
  end
end
