module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :require_admin

    def index
      @users = User.by_creation_date.all
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      password = Devise.friendly_token.first(16)
      @user = User.new(user_params.merge(password: password))

      if @user.save
        redirect_to admin_users_url, success: "User was successfully created."
      else
        render :new
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_url, success: "User was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_url, success: "User was successfully destroyed."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      parameters = params.require(:user).permit(:email, :role)
      parameters.delete("role") unless current_user.has_role?(params.dig("user", "role"))
      parameters
    end
  end
end
