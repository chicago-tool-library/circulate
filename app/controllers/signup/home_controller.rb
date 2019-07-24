module Signup
  class HomeController < BaseController
    def index
      @borrow_policy = Document.borrow_policy
      @hide_steps = true
    end
  end
end
