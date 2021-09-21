class TestController < ApplicationController
  def google_auth
    session[:email] = params[:email]
    head :no_content
  end
end
