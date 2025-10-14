module Admin
  class UsersController < BaseController
    include Pagy::Backend

    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :require_admin

    def index
      @pagy, @users = pagy(users_index_query)
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
        redirect_to admin_users_url, success: "User was successfully created.", status: :see_other
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_url, success: "User was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_url, success: "User was successfully destroyed.", status: :see_other
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

    def users_index_query
      users_query = User.by_creation_date.all

      case params[:filter]
      when "admin"
        users_query.admin
      when "staff"
        users_query.staff
      when "members"
        users_query.member
      else
        users_query
      end
    end
  end
end
