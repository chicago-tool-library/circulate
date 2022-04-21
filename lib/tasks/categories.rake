namespace :categories do
  desc "Updates the category_nodes materialized view"
  task refresh_nodes: :environment do
    CategoryNode.refresh
  end

  desc "Update the category counts for all categories"
  task update_category_counts: :environment do
    Category.find_each do |category|
      category.update_item_counts
    end
    CategoryNode.refresh
  end
end
