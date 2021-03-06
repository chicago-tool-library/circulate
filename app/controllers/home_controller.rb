class HomeController < ApplicationController
  before_action :index do
    redirect_to account_home_url if user_signed_in?
  end

  def index
    @body_class = "landing-page"
  end
end
