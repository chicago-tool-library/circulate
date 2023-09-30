# frozen_string_literal: true

module Admin
  module Reports
    class MemberRequestsController < BaseController
      include MemberOrdering

      def index
        @members = Member.open.order(index_order)
      end
    end
  end
end
