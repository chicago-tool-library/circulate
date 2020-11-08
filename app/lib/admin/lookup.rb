module Admin
  class Lookup
    include ActiveModel::Model

    attr_reader :item
    attr_reader :item_name_or_number
    # attr_reader :items_by_name_or_number

    validates_each :item do |record, attr, value|
      unless value
        record.errors.add(:item_name_or_number, "no item with that name or number")
      end
    end

    def item_name_or_number=(item_name_or_number)
      Item.name_or_number_contains(item_name_or_number).by_name
    end
  end
end
