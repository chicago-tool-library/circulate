module ItemsHelper
  def item_categories(item)
    item.categories.map(&:name).sort.join(", ") 
  end
end
