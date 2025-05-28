module Admin
  class FlaggedItemsController < BaseController
    include Pagy::Backend
    include MemberOrdering

    def index
      @items_pagy, @items = pagy(
        Item.all.order(item_index_order).includes(:categories, :borrow_policy, :active_holds).with_attached_image.where(flagged: true),
        items: 10
      )

      @members_pagy, @members = pagy(
        Member.all.order(index_order).includes(:active_membership, :last_membership, :checked_out_loans, :active_holds).where(flagged: true),
        items: 10
      )
    end

    private

    def item_index_order
      options = {
        "name" => "items.name ASC",
        "number" => "items.number ASC",
        "added" => "items.created_at DESC"
      }
      Arel.sql options.fetch(params[:sort]) { options["name"] }
    end
  end
end
