module CategoriesHelper
  def full_category_parent_name(category)
    category.ancestors.map(&:name).join(" > ")
  end

  def full_category_name(category)
    (category.ancestors.map(&:name) << category.name).join(" > ")
  end
end
