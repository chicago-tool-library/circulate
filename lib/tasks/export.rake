require "csv"

namespace :export do
  desc "Export verified members to CSV"
  task verified_members_to_csv: :environment do
    columns = %w[id preferred_name email]
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "verified_members-#{now}.csv"
    puts "writing member info to #{path}"

    CSV.open(path, "wb") do |csv|
      csv << [
        *columns
      ]
      Member.verified.in_batches(of: 100) do |members|
        members.each do |member|
          csv << [
            *member.attributes.values_at(*columns)
          ]
        end
      end
    end
  end

  desc "Export items to CSV"
  task items_to_csv: :environment do
    columns = %w[
      id name description size brand model serial strength
      quantity checkout_notice status created_at updated_at
    ]
    CSV.open(Rails.root + "exports" + "all_items.csv", "wb") do |csv|
      csv << [
        "complete_number",
        "code",
        "number",
        "categories",
        *columns
      ]
      Item.includes(:borrow_policy, :categories).in_batches(of: 100) do |items|
        items.each do |item|
          csv << [
            item.complete_number,
            item.borrow_policy.code,
            item.number,
            item.categories.map(&:name).sort.join(", "),
            *item.attributes.values_at(*columns)
          ]
        end
      end
    end
  end
end
