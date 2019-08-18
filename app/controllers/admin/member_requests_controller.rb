module Admin
  class MemberRequestsController < BaseController
    include MemberOrdering

    def index
      @members = Member.open.order(index_order)
    end
  end
end