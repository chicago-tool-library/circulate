module Admin
  class ManageFeaturesController < BaseController
    def index
      @current_library = current_library
    end

    def update
      checked_value = {"0": false, "1": true}
      membership_param = params[:library][:allow_members]
      payments_params = params[:library][:allow_payments]
      membership_changed = checked_value[params[:library][:allow_members].to_sym] != @current_library.allow_members
      payments_changed = checked_value[params[:library][:allow_payments].to_sym] != @current_library.allow_payments

      if membership_changed
        Library.find(@current_library.id).update_column :allow_members, membership_param
      end
      if payments_changed
        Library.find(@current_library.id).update_column :allow_payments, payments_params
      end

      if membership_changed || payments_changed
        redirect_to admin_manage_features_url, success: "You have successfully updated the library"
      else
        redirect_to admin_manage_features_url, warning: "You didn't make any changes"
      end
    end
  end
end
