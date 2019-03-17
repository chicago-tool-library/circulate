module CategoriesHelper
  def full_category_name(category)
    (category.ancestors.map(&:name) << category.name).join(" > ")
  end
end