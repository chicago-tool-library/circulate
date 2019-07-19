module Signup
  class HomeController < BaseController
    def index
      @borrow_policy = Document.borrow_policy
    end
  end
end
