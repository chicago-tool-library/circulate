module Admin
  module Reports
    class MemberRequestsController < BaseController
      include Pagy::Backend
      include MemberOrdering

      def index
        @members = Member.open.order(index_order)

        respond_to do |format|
          format.html do
            @pagy, @members = pagy_arel(@members, items: 100)
          end
        end
      end
    end
  end
end
