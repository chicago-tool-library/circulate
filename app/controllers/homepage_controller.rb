class HomepageController < ApplicationController
  layout "homepage"

  def index; end

  def create
    HomepageMailer.with(homepage_params: homepage_params[:homepage]).inquiry.deliver_later

    redirect_to homepage_index_path
    # , flash: { success: "Your request has been submitted." }
  end

  private

  def homepage_params
    params.permit(homepage: %i[name email city state country description inventory])
  end
end
