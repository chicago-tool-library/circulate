class ApplicationController < ActionController::Base
  add_flash_types :success, :error, :warning

  before_action :authenticate_user!
end
