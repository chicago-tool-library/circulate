module Admin
  class Lookup
    include ActiveModel::Model

    attr_reader :item
    attr_reader :item_number
    # attr_reader :item_name

    validates_each :item do |record, attr, value|
      unless value
        record.errors.add(:item_number, "no item with that number")
        # record.errors.add(:item_name, "no item with that name")
      end
    end

    def item_number=(item_number)
      @item_number = item_number
      @item = Item.find_by(number: item_number)
    end

    # def item_name=(item_name)
    #   @item_name = item_name
    #   # @item = Item.find_by(name: item_name)
    #   @item = Item.name_contains(@query).by_name
    # end
  end
end
