require "csv"

namespace :import do
  def update_item_with_row(row)
    id = row["id"]
    item = Item.find(id)

    if item.number != row["inventory number"].to_i
      raise "wrong number for item with id #{id}"
    end

    attributes = %w[name other_names size brand model strength checkout_notice power_source description].each_with_object({}) do |field, sum|
      sum[field] = row[field] unless row[field].blank? || row[field] == "NULL"
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

  desc "Updates items with categories"
  task category_csv: :environment do

    class Category
      def refresh_category_nodes
        # no need to do this after every change
      end
    end

    path = ENV["CSV_FILE"]
    library = Library.find(ENV["LIBRARY_ID"])
    user = User.find_by!(email: ENV["AUTHOR"])

    CSV.foreach(path, headers: true) do |row|
      Audited.audit_class.as_user(user) do
        ActsAsTenant.with_tenant(library) do
          item = Item.find_by(id: row["id"])
          unless item
            puts "no item found for id #{row["id"]}"
            next
          end

          next if row["categories"].to_s == ""
          path_names = row["categories"].split(";").map(&:strip).reject(&:empty?).uniq
          category_ids = CategoryNode.where("ARRAY_TO_STRING(path_names, '//') IN (?)", path_names).pluck(:id)

          if path_names.size != category_ids.size
            puts "creating missing category"
            create_missing_categories(path_names)
          end

          category_ids = CategoryNode.where("ARRAY_TO_STRING(path_names, '//') IN (?)", path_names).pluck(:id)

          if path_names.size != category_ids.size
            puts "wrong number of categories found for item #{row["id"]}: wanted #{path_names.size}, got #{category_ids.size}"
            puts path_names
          end

          item.update!(category_ids: category_ids)
        end
      end
    end

    CategoryNode.refresh
  end

  def create_missing_categories(path_names)
    path_names.each do |path|
      path.split("//").inject(Category.all) { |parent, name|
        parent.find_or_create_by!(name: name.strip).children
      }
    end
  rescue ActiveRecord::RecordInvalid
    puts "failed to save category"
    nil
  end
end
