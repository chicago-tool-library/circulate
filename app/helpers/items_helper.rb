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
    BorrowPolicy.alpha_by_code.map do |borrow_policy|
      ["(#{borrow_policy.code}) #{borrow_policy.name}: #{borrow_policy.description}", borrow_policy.id]
    end
  end

  def category_nav(categories, current_category = nil)
    return unless categories

    tag.div class: "nav" do
      categories.map { |category|
        tag.li(class: "nav-item #{"active" if category == current_category}") {
          link_to(category.name, category: category.id)
        }
      }.join.html_safe
    end
  end
end
