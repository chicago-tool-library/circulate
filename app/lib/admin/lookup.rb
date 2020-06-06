module Admin
  class Lookup
    include ActiveModel::Model

    attr_reader :item
    attr_reader :item_number

    validates_each :item do |record, attr, value|
      unless value
        record.errors.add(:item_number, "no item with that number")
      end
    end

    def item_number=(item_number)
      @item_number = item_number
      @item = Item.find_by(number: item_number)
    end
  end
end
