module Admin
  module GroupLendingHelper
    def item_pool_options
      ItemPool.all.map { |item_pool| [item_pool.name, item_pool.id] }
    end
  end
end
