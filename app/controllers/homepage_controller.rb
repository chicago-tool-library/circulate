class HomepageController < ApplicationController
  layout "homepage"

  def index; end

  def create
    byebug
    redirect_to homepage_index_path
  end
end
