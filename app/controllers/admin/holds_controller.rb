module Admin
  class HoldsController < BaseController
    include Pagy::Backend

    def index
      holds_scope = Hold.active.includes(:member, item: :borrow_policy).order("expires_at ASC NULLS LAST, created_at ASC")
      @pagy, @holds = pagy(holds_scope, items: 100)
    end

    private
  end
end
