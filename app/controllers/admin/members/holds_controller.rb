module Admin
  module Members
    class HoldsController < BaseController
      include ActionView::RecordIdentifier

      def index
        @holds = @member.active_holds.includes(:item)
      end

      def create
        @item = Item.find(new_hold_params[:item_id])

        @hold = Hold.new(item: @item, member: @member, creator: current_user)

        @hold.transaction do
          if @hold.save
            @hold.start! if @hold.ready_for_pickup?
            redirect_to admin_member_holds_path(@member, anchor: dom_id(@hold))
          else
            flash[:checkout_error] = @hold.errors.full_messages_for(:item_id).join
            redirect_to admin_member_holds_path(@member, anchor: "checkout")
          end
        end
      end

      def lend
        @hold = @member.active_holds.find(params[:id])
        Loan.lend(@hold.item, to: @member).tap do |loan|
          @hold.lend(loan)
        end
        redirect_to admin_member_holds_path(@hold.member)
      end

      def destroy
        @hold = @member.active_holds.find(params[:id])

        @hold.destroy!
        redirect_to admin_member_holds_path(@hold.member)
      end

      private

      def new_hold_params
        params.require(:hold).permit(:item_id)
      end
    end
  end
end
