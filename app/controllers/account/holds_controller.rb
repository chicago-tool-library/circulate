module Account
  class HoldsController < BaseController
    
    def create
      new_hold_save
      redirect_to item_path(item), flash: create_redirect_flash
    end

    private

    delegate :save, to: :new_hold, prefix: true, private: true
    delegate :persisted?, to: :new_hold, prefix: true, private: true

    def item
      @item ||= Item.find(params[:item_id])
    end

    def new_hold
      @new_hold ||= Hold.new(item: item, member: current_member, creator: current_user)
    end

    def create_redirect_flash
      if new_hold_persisted?
        {success: "Hold placed."}
      else
        {error: "Something went wrong!"}
      end
    end
  end
end