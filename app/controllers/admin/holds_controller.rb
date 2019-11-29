module Admin
  class HoldsController < BaseController
    include Pagy::Backend

    def index
      holds_scope = Hold.active
      @pagy, @holds = pagy(holds_scope, items: 100)
    end

    private
  end
end
