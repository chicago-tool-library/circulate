module Admin
  module Members
    class NotesController < BaseController
      include ActionView::RecordIdentifier

      before_action :load_member

      def create
        @note = @member.notes.new(note_params.merge(creator: current_user))

        if @note.save
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to admin_member_path(@member) }
          end
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        load_note

        if @note.update(note_params)
          respond_to do |format|
            format.turbo_stream
            format.html do
              redirect_to admin_member_path(@member, anchor: dom_id(@note)),
                notice: "Note updated successfully.",
                status: :see_other
            end
          end
        else
          render :edit, status: :unprocessable_content
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
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_member_path(@member), notice: "Note deleted." }
        end
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
