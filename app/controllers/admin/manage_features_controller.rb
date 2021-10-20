module Admin
  class ManageFeaturesController < BaseController
    def index
      @current_library = current_library
    end

    def update
      if check_for_edit == true
        Library.find(@current_library.id).update(library_feature_params)
        redirect_to admin_manage_features_url, success: "You have successfully updated the library"
      else
        redirect_to admin_manage_features_url, warning: "You didn't make any changes"
      end
    end

    private

    def check_for_edit
      checked_value = {"0": false, "1": true}

      library_feature_params.keys.each do |feature|
        return true if checked_value[library_feature_params[feature].to_sym] != @current_library[feature]
      end
    end

    def library_feature_params
      params.require(:library).permit(:allow_members, :allow_appointments, :allow_payments)
    end
  end
end
