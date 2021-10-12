class HomepageController < ApplicationController
  def index; end

  def create
    redirect_to homepage_index_path
  end
end
