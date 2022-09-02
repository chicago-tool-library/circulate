require "csv"

# BorrowPolicy.create!(library_id: 1, code: "S", consumable: true, uniquely_numbered: false, name: "Single Use")

namespace :import do
  def update_item_with_row(row)
    id = row["id"]

    item = if id.blank?
      Item.new
    else
      Item.find(id)
      # .tap do |item|
      #   if item.number != row["number"].to_i
      #     raise "wrong number for item with id #{id}: database has #{item.number}, import has #{row["number"]}"
      #   end
      # end
    end

    attributes = %w[name other_names size brand model strength checkout_notice power_source description quantity status url purchase_link purchase_price].each_with_object({}) do |field, sum|
      sum[field] = row[field].strip unless row[field].blank? || row[field] == "NULL"
    end

    # attributes["power_source"] = row["power_source"] == "not powered" ? nil : row["power_source"]

    # attributes["borrow_policy_id"] = BorrowPolicy.where(code: row["new_code"]).first.id
    # attributes["quantity"] ||= 0 if row["new_code"] == "S"
    # attributes["category_ids"] = find_or_create_categories_from_names(item.id, row["categories"])

    item.attributes = attributes
    item.save!

    puts "updated item #{id}"
  rescue ActiveRecord::RecordNotFound => e
    puts e.inspect
  end

  desc "Loads and updates items from a CSV"
  task item_csv: :environment do
    path = ENV["CSV_FILE"]
    user = User.find_by(email: ENV["AUTHOR"])

    raise "author not found!" unless user

    library = Library.find(ENV["LIBRARY_ID"])

    CSV.foreach(path, headers: true) do |row|
      Audited.audit_model.as_user(user) do
        ActsAsTenant.with_tenant(library) do
          update_item_with_row(row)
        end
      end
    end
  end

  def find_or_create_categories_from_names(item_id, names)
    path_names = names.split(";").map(&:strip).reject(&:empty?).uniq
    category_ids = CategoryNode.where("ARRAY_TO_STRING(path_names, '//') IN (?)", path_names).pluck(:id)

    if path_names.size != category_ids.size
      puts "creating missing category"
      create_missing_categories(path_names)
    end

    category_ids = CategoryNode.where("ARRAY_TO_STRING(path_names, '//') IN (?)", path_names).pluck(:id)

    if path_names.size != category_ids.size
      puts "wrong number of categories found for item #{item_id}: wanted #{path_names.size}, got #{category_ids.size}"
      puts path_names
      nil
    else
      category_ids
    end
  end

  desc "Updates items with categories"
  task category_csv: :environment do
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class Category
      def refresh_category_nodes
        # no need to do this after every change
      end
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

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

          category_ids = find_or_create_categories_from_names(item.id, row["categories"])
          item.update!(category_ids: category_ids) if category_ids
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
    CategoryNode.refresh
  rescue ActiveRecord::RecordInvalid
    puts "failed to save category"
    nil
  end
end
