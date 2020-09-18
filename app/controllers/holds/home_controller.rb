module Holds
  class HomeController < BaseController
    def index
      activate_step(:items)
    end
  end
end
