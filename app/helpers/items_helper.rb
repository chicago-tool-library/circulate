module ItemsHelper
  def item_categories(item)
    item.categories.map(&:name).sort.join(", ") 
  end

  def item_status_options
    explainations = {
      "pending" => "just acquired; not ready to loan",
      "active" => "available to loan",
      "maintenance" => "needs repair; do not loan",
      "retired" => "no longer part of our inventory",
    }
    Item.statuses.map do |key, value|
      ["#{key.titleize} (#{explainations[key]})", key]
    end
  end
end
