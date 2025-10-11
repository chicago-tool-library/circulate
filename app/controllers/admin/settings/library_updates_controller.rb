class Admin::Settings::LibraryUpdatesController < Admin::BaseController
  before_action :require_admin
  include ActionView::RecordIdentifier

  before_action :set_library_update, only: [:show, :edit, :update, :destroy]

  def index
    @library_updates = LibraryUpdate.newest_first.all
  end

  def new
    @library_update = LibraryUpdate.new
  end

  def edit
  end

  def show
  end

  def create
    @library_update = LibraryUpdate.new(library_update_params)

    if @library_update.save
      redirect_to admin_settings_library_updates_url(anchor: dom_id(@library_update)), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @library_update.update(library_update_params)
      redirect_to admin_settings_library_updates_url(anchor: dom_id(@library_update)), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @library_update.destroy
    redirect_to admin_settings_library_updates_url, success: "Library Update was successfully destroyed.", status: :see_other
  end

  private

  def set_library_update
    @library_update = LibraryUpdate.find(params[:id])
  end

  def library_update_params
    params.require(:library_update).permit(:title, :body, :published)
  end
end
