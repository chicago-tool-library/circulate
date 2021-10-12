module Admin
  class ManageFeaturesController < BaseController
    def index
      @current_library = current_library
    end

    def update
      Library.find(@current_library.id).update_column :allow_members, params[:library][:allow_members]
      redirect_to admin_manage_features_url, success: "You have successfully updated the library"
    end
  end
end
