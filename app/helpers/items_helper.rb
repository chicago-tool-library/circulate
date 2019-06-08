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

  def borrow_policy_options
    BorrowPolicy.all.map do |borrow_policy|
      [borrow_policy.name, borrow_policy.id]
    end
  end

  def category_nav(categories, current_category=nil)
    return unless categories

    tag.div class: "nav" do
      categories.keys.sort_by {|c| c.name }.map do |category|
        tag.li(class: "nav-item #{'active' if category == current_category}") do
          link_to(category.name, category: category.id)
        end +
        category_nav(categories[category], current_category)
      end.join.html_safe
    end
  end
end
