class Admin::NotesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :load_parent

  def create
    @note = @parent.notes.create(note_params.merge(creator: current_user))

    if @note.save
      redirect_to [:admin, @parent], anchor: dom_id(@note)
    else
      render "new"
    end
  end

  private

  def note_params
    params.require(:note).permit(:body)
  end

  def load_parent
    @parent = if params[:item_id]
      Item.find(params[:item_id])
    end
    raise ActiveRecord::RecordNotFound unless @parent
  end
end
