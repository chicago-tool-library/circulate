module Admin
  class MemberHoldsController < BaseController
    include ActionView::RecordIdentifier

    before_action :load_member

    def index
      @holds = @member.holds.active.includes(:item)
    end

    def create
      @item = Item.find(new_hold_params[:item_id])

      @hold = Hold.new(item: @item, member: @member, creator: current_user)

      if @hold.save
        redirect_to admin_member_member_holds_path(@member, anchor: dom_id(@hold))
      else
        flash[:checkout_error] = @hold.errors.full_messages_for(:item_id).join
        redirect_to admin_member_member_holds_path(@member, anchor: "checkout")
      end
    end

    def destroy
      @hold = @member.holds.find(params[:id])

      @hold.destroy!
      redirect_to admin_member_member_holds_path(@hold.member)
    end

    private

    def new_hold_params
      params.require(:hold).permit(:item_id)
    end

    def load_member
      @member = Member.find(params[:member_id])
    end
  end
end
