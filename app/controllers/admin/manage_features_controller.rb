module Admin
  class ManageFeaturesController < BaseController
    def index
      @current_library = current_library
    end

    def update
      Library.find(@current_library.id).update_column :allow_members, params[:library][:allow_members]
    end
  end
end
