module Admin
  class CheckOut
    include ActiveModel::Model

    attr_reader :item
    attr_reader :item_number
    attr_accessor :member

    validates :member, presence: true

    validates_each :item do |record, attr, value|
      if value
        value.reload
        if value.checked_out_exclusive_loan
          record.errors.add(:item_number, "is already on loan")
        elsif !value.active?
          record.errors.add(:item_number, "is not available to loan")
        end
      else
        record.errors.add(:item_number, "does not exist")
      end
    end

    def item_number=(item_number)
      @item_number = item_number
      @item = Item.where(number: item_number).first
    end

    def item_id
      @item&.id
    end
  end
end
