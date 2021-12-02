module Admin
  class NotesController < BaseController
    include ActionView::RecordIdentifier
    include PortalRendering

    before_action :load_parent

    def create
      @note = @parent.notes.create(note_params.merge(creator: current_user))

      if @note.save
        redirect_to [:admin, @parent, anchor: dom_id(@note)]
      else
        render_to_portal "form", locals: {parent: @parent, note: @note}, status: 422
      end
    end

    def update
      @note = @parent.notes.find(params[:id])

      if @note.update(note_params)
        redirect_to [:admin, @parent, anchor: dom_id(@note)]
      else
        render_to_portal "form", locals: {parent: @parent, note: @note}, status: 422
      end
    end

    def new
      @note = @parent.notes.new
    end

    def edit
      @note = @parent.notes.find(params[:id])

      if @parent.is_a?(Member)
        render "_form", locals: {parent: @parent, note: @note}
      else
        render_to_portal "form", locals: {parent: @parent, note: @note}
      end
    end

    def show
      @note = @parent.notes.find(params[:id])
      render_to_portal "show", locals: {parent: @parent, note: @note}
    end

    def destroy
      @parent.notes.find(params[:id]).destroy!
      redirect_to [:admin, @parent], flash: {success: "Note has been deleted."}
    end

    private

    def note_params
      params.require(:note).permit(:body)
    end

    def load_parent
      if params[:item_id]
        @parent = Item.find(params[:item_id])
      elsif params[:member_id]
        @parent = Member.find(params[:member_id])
      end
      raise ActiveRecord::RecordNotFound unless @parent
    end
  end
end
