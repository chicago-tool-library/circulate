module SuperAdmin
  class LibrariesController < ApplicationController
    before_action :require_super_admin

    def index
      @libraries = Library.all
    end

    def new
      @library = Library.new
    end

    def create
      @library = Library.create(params.require(:library).permit(:name, :hostname))
      redirect_to libraries_path
    end

    def show
      @library = Library.find(params[:id])
    end

    def edit
      @library = Library.find(params[:id])
    end

    def update
      @library = Library.find(params[:id])
      @library.update(params.require(:library).permit(:name, :hostname))
      redirect_to library_path(@library)
    end

    def destroy
      @library = Library.find(params[:id])
      @library.destroy
      redirect_to libraries_path
    end

    private

    def require_super_admin
      unless current_user.super_admin?
        redirect_to items_path, warning: "You do not have access to that page."
      end
    end
  end
end
