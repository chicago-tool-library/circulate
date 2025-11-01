module Account
  class ForLaterListItemsController < BaseController
    include Pagy::Backend

    def index
      scope = current_member.for_later_list_items.includes(item: [:borrow_policy, :active_holds, :checked_out_exclusive_loan, :categories]).strict_loading
      @pagy, @for_later_list_items = pagy(scope, items: 20)
    end

    def create
      for_later_list_item = ForLaterListItem.new(for_later_list_item_params)
      for_later_list_item.member = current_member

      for_later_list_item.save!

      item = for_later_list_item.item

      respond_to do |format|
        format.html { redirect_to item_path(for_later_list_item.item) }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("for_later_list_item_show", partial: "items/for_later_list_item_show", locals: {item:, for_later_list_item:}),
            turbo_stream.replace("#{helpers.dom_id(item)}_for_later_list_items_index", partial: "items/for_later_list_items_index", locals: {item:, for_later_list_item:})
          ]
        end
      end
    end

    def destroy
      for_later_list_item = current_member.for_later_list_items.find(params.expect(:id))

      for_later_list_item.destroy!

      item = for_later_list_item.item

      respond_to do |format|
        format.html { redirect_to account_for_later_list_items_path }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(helpers.dom_id(for_later_list_item)),
            turbo_stream.replace("for_later_list_item_show", partial: "items/for_later_list_item_show", locals: {item:, for_later_list_item: nil}),
            turbo_stream.replace("#{helpers.dom_id(item)}_for_later_list_items_index", partial: "items/for_later_list_items_index", locals: {item:, for_later_list_item: nil})
          ]
        end
      end
    end

    private

    def for_later_list_item_params
      params.expect(for_later_list_item: [:item_id])
    end
  end
end
