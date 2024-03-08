module Admin
  module GroupLendingHelper
    def item_pool_options
      ItemPool.all.map { |item_pool| [item_pool.name, item_pool.id] }
    end

    def item_pool_options_for_reservable_items
      ItemPool.uniquely_numbered.map { |item_pool| [item_pool.name, item_pool.id] }
    end
  end
end
