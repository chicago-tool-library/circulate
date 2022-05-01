module Admin
  module Settings
    class EmailSettingsController < BaseController
      def show
      end

      def edit
        @library = current_library
      end

      def update
        current_library.update(email_settings_params)
        redirect_to admin_settings_email_settings_url, success: "Email settings updated"
      end

      def preview
        @library = current_library
        @preview = true
        render layout: "mailer"
      end

      private

      def email_settings_params
        params.require(:library).permit(:email_banner1, :email_banner2)
      end
    end
  end
end
