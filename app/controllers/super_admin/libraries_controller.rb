module SuperAdmin
  class LibrariesController < ApplicationController
    skip_before_action :set_tenant
    before_action :require_super_admin

    layout :custom_layout

    def index
      @libraries = Library.all
    end

    def new
      @library = Library.new
    end

    def create
      @library = Library.new(library_params)

      if @library.save
        redirect_to super_admin_libraries_path, success: "Library successfully created.", status: :see_other
      else
        respond_to do |format|
          format.html { render :new, status: unprocessable_entity }
        end
      end
    end

    def show
      @library = Library.find(params[:id])
    end

    def edit
      @library = Library.find(params[:id])
    end

    def update
      @library = Library.find(params[:id])

      if @library.update(library_params)
        redirect_to super_admin_library_path(@library), success: "Library successfully updated.", status: :see_other
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @library = Library.find(params[:id])
      @library.destroy
      redirect_to super_admin_libraries_path, success: "Library successfully deleted.", status: :see_other
    end

    private

    def custom_layout
      return "turbo_rails/frame" if turbo_frame_request?

      "admin"
    end

    def require_super_admin
      unless current_user.super_admin?
        redirect_to items_path, warning: "You do not have access to that page."
      end
    end

    def library_params
      params.require(:library).permit(:name, :hostname, :city, :email, :address, :member_postal_code_pattern, :image)
    end
  end
end
