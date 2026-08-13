module Account
  class HoldsController < BaseController
    LIMIT_MESSAGE_ITEM_COUNT = 5

    include Pagy::Backend

    def index
      @holds = current_member.active_holds.recent_first.joins(:item).merge(Item.holdable)
    end

    def create
      @item = Item.find(params[:item_id])

      unless @item.holds_enabled
        redirect_to item_path(@item), error: "Can't be placed on hold", status: :see_other
        return
      end

      @new_hold = Hold.new(item: @item, member: current_member, creator: current_user)

      @new_hold.transaction do
        if @new_hold.save
          ahoy.track "Placed hold", hold_id: @new_hold.id
          @new_hold.start! if @new_hold.ready_for_pickup?
          redirect_to item_path(@item), success: "Hold placed.", status: :see_other
        else
          error = if @new_hold.errors.of_kind?(:base, :maximum_items_per_member)
            borrow_policy_limit_message(@new_hold)
          else
            @new_hold.errors.full_messages.to_sentence
          end
          redirect_to item_path(@item), error:, status: :see_other
        end
      end
    end

    def destroy
      hold = current_member.active_holds.find(params[:id])
      hold.cancel!

      redirect_to account_holds_path, status: :see_other
    end

    def history
      @pagy, @holds = pagy(current_member.inactive_holds.recent_first.includes(:item))
    end

    private

    def borrow_policy_limit_message(hold)
      borrow_policy = hold.item.borrow_policy
      tool_name = "#{borrow_policy.code}-Tool".pluralize(borrow_policy.maximum_items_per_member)
      introduction = helpers.tag.p(
        "You can have a maximum of #{borrow_policy.maximum_items_per_member} #{tool_name} checked out or on hold at one time. These items count toward your limit:"
      )
      counted_items = hold.existing_items_counted_toward_limit
      items = counted_items.first(LIMIT_MESSAGE_ITEM_COUNT).map do |item_holder|
        status = item_holder.is_a?(Loan) ? "checked out" : "on hold"
        helpers.tag.li do
          item_name = helpers.truncate(item_holder.item.complete_number_and_name, length: 100)
          helpers.link_to(item_name, item_path(item_holder.item)) + " (#{status})"
        end
      end
      remaining_item_count = counted_items.size - items.size
      items << helpers.tag.li("and #{remaining_item_count} more") if remaining_item_count.positive?
      next_step = helpers.tag.p("Return or cancel one before placing another hold.")

      helpers.safe_join([introduction, helpers.tag.ul(helpers.safe_join(items)), next_step])
    end
  end
end
