class HomepageController < ApplicationController
  layout "homepage"

  def index; end

  def create
    redirect_to homepage_index_path
  end
end
