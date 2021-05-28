require "csv"

namespace :import do

  def update_item_with_row(row)
    id = row["id"]
    item = Item.find(id)

    if item.number != row["inventory number"].to_i
      raise "wrong number for item with id #{id}"
    end

    attributes = %w{name other_names size brand model strength checkout_notice power_source description}.inject({}) do |sum, field|
      sum[field] = row[field] unless row[field].blank? || row[field] == "NULL"
      sum
    end

    attributes["power_source"] = row["power_source"] == "not powered" ? nil : row["power_source"]

    puts item.attributes.slice(*attributes.keys).inspect
    item.update!(attributes)
    puts item.attributes.slice(*attributes.keys).inspect
    puts "updated item #{id}"

  rescue ActiveRecord::RecordNotFound
    puts "Item with id #{id} not found!"
  end

  desc "Loads and updates items from a CSV"
  task item_csv: :environment do
    path = ENV["CSV_FILE"]
    user = User.find_by(email: ENV["AUTHOR"])

    raise "author not found!" unless user

    CSV.foreach(path, headers: true) do |row|
      Audited.audit_class.as_user(user) do
        update_item_with_row(row)
      end
    end

  end
end