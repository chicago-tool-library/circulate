module Users
  class ConfirmationsController < Devise::ConfirmationsController
    private

    # The path used after confirmation.
    def after_confirmation_path_for(resource_name, resource)
      if params[:org]
        return signup_organizations_approval_path
      end
      if signed_in?(resource_name)
        signed_in_root_path(resource)
      else
        new_session_path(resource_name)
      end
    end
  end
end
