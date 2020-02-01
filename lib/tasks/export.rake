require "csv"

desc "Export items to CSV"
task :export_items_to_csv => :environment do
  columns = %w{
    id name description size brand model serial strength 
    quantity checkout_notice status created_at updated_at
  }
  CSV.open(Rails.root + "exports" + "all_items.csv", "wb") do |csv|
    csv << [
      "complete_number",
      "code",
      "number",
      "tags",
      *columns,
    ]
    Item.includes(:borrow_policy, :tags).in_batches(of: 100) do |items|
      items.each do |item|
        csv << [
          item.complete_number,
          item.borrow_policy.code,
          item.number,
          item.tags.map(&:name).sort.join(", "),
          *item.attributes.values_at(*columns),
        ]
      end
    end
  end
end