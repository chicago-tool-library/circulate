# frozen_string_literal: true

module Admin
  class ManualImportsController < BaseController
    def edit
      @item = Item.active.find(params[:item_id])
      @manual_import = ManualImport.new
    end

    def update
      @item = Item.active.find(params[:item_id])
      @manual_import = ManualImport.new(manual_import_params)
      if @manual_import.valid?
        @manual_import.update_item!(@item)
        redirect_to admin_item_path(@item), success: "The manual was imported."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
      def manual_import_params
        params.require(:manual_import).permit(:url)
      end
  end
end
