module Admin
  module Members
    class NotesController < BaseController
      include ActionView::RecordIdentifier

      before_action :load_member

      def create
        @note = @member.notes.create(note_params.merge(creator: current_user))

        if @note.save
          respond_to do |format|
            format.turbo_stream
          end
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        load_note

        if @note.update(note_params)
          redirect_to [:admin, @member, anchor: dom_id(@note)], status: :see_other
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def new
        @note = @member.notes.new
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

      def index
        @notes = @member.notes.newest_first.with_all_rich_text
        render layout: false if request.format.turbo_stream?
      end
      
      
      
      private

      def note_params
        params.require(:note).permit(:body, :pinned)
      end

      def load_note
        @note = @member.notes.find(params[:id])
      end
    end
  end
end
