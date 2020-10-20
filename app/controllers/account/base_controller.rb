module Account
  class BaseController < ApplicationController
    before_action :authenticate_user!
  end
end
