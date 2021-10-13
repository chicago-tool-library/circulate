module Admin
  class ManageFeaturesController < BaseController
    def index
      @current_library = current_library
    end

    def update
      checked_value = { "0": false, "1": true }

      if checked_value[params[:library][:allow_members].to_sym] != @current_library.allow_members
        Library.find(@current_library.id).update_column :allow_members, params[:library][:allow_members]
        redirect_to admin_manage_features_url, success: "You have successfully updated the library"
      else
        redirect_to admin_manage_features_url, warning: "You didn't make any changes"
      end
    end
  end
end
