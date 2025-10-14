module Admin
  module Items
    class NotesController < BaseController
      include ActionView::RecordIdentifier

      before_action :load_item

      def create
        @note = @item.notes.create(note_params.merge(creator: current_user))

        if @note.save
          respond_to do |format|
            format.turbo_stream
          end
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        load_note

        if @note.update(note_params)
          redirect_to [:admin, @item, anchor: dom_id(@note)], status: :see_other
        else
          render :edit, status: :unprocessable_content
        end
      end

      def new
        @note = @item.notes.new
      end

      def edit
        load_note
      end

      def show
        load_note
      end

      def destroy
        load_note
        @note.destroy!
      end

      private

      def note_params
        params.require(:note).permit(:body)
      end

      def load_note
        @note = @item.notes.find(params[:id])
      end
    end
  end
end
