module Admin
  module Items
    class AttachmentsController < BaseController
      def index
        @attachments = @item.attachments
      end

      def new
        @attachment = @item.attachments.new
      end

      def create
        @attachment = @item.attachments.create(attachment_params.merge(creator: current_user))

        if @attachment.save
          redirect_to admin_item_attachments_path(@item)
        else
          render :new, status: 422
        end
      end

      def update
        @attachment = @item.attachments.find(params[:id])

        if @attachment.update(attachment_params)
          redirect_to admin_item_attachments_path(@item)
        else
          render :edit, status: 422
        end
      end

      def edit
        @attachment = @item.attachments.find(params[:id])
      end

      def show
        @attachment = @item.attachments.find(params[:id])
      end

      private

      def attachment_params
        params.require(:item_attachment).permit(:file, :kind, :other_kind, :notes)
      end
    end
  end
end
