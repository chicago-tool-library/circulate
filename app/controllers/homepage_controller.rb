class HomepageController < ApplicationController
  layout "homepage"

  def index
  end

  def create
    HomepageMailer.with(homepage_params: homepage_params[:homepage]).inquiry.deliver_later

    # TO DO: render flash message on redirection
    redirect_to homepage_index_path
  end

  private

  def homepage_params
    params.permit(homepage: %i[name email city state country description inventory])
  end
end
