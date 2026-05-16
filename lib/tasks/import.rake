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

  # Updates item locations from a CSV with headers including:
  #   complete_number, name, location_area, location_shelf
  # Other columns are ignored. Joins on complete_number rather than `id`.
  # The CSV's id column is not a reliable join key (the May 2026 spreadsheet
  # had 118 duplicate ids); complete_number maps cleanly via
  # Item.find_by_complete_number.
  #
  # To run without redeploying (the May 2026 recipe), tar the script + CSV
  # together and pipe to a one-off dyno:
  #
  #   tar -c -C /tmp import_locations.rb tool_locations.csv | \
  #     heroku run --no-tty --app chicagotoollibrary -- bash -c '
  #       set -e
  #       cd /tmp && tar x
  #       AUTHOR=you@chicagotoollibrary.org LIBRARY_ID=1 DRY_RUN=1 \
  #         CSV_FILE=/tmp/tool_locations.csv \
  #         rails runner /tmp/import_locations.rb
  #     '
  #
  # Or after deploying the rake task:
  #
  #   heroku run rake import:item_locations \
  #     CSV_FILE=/tmp/locations.csv AUTHOR=email LIBRARY_ID=1 DRY_RUN=1
  desc "Updates item locations (location_area, location_shelf) from a CSV"
  task item_locations: :environment do
    path = ENV["CSV_FILE"]
    user = User.find_by(email: ENV["AUTHOR"])
    raise "author not found!" unless user

    library = Library.find(ENV["LIBRARY_ID"])
    dry_run = ENV["DRY_RUN"] == "1"

    puts "DRY RUN: no changes will be saved" if dry_run

    stats = Hash.new(0)

    CSV.foreach(path, headers: true) do |row|
      Audited.audit_model.as_user(user) do
        ActsAsTenant.with_tenant(library) do
          complete_number = row["complete_number"]
          item = Item.find_by_complete_number(complete_number)

          unless item
            puts "SKIP #{complete_number}: item not found (csv name=#{row["name"].inspect})"
            stats[:skipped_not_found] += 1
            next
          end

          if row["location_area"].to_s.strip.empty?
            puts "SKIP #{complete_number} (#{item.name.inspect}): blank location_area in CSV"
            stats[:skipped_missing_area] += 1
            next
          end

          if row["name"].to_s.strip.present? && row["name"].strip != item.name.to_s.strip
            puts "NAME MISMATCH #{complete_number}: db=#{item.name.inspect} csv=#{row["name"].inspect} (updating location anyway)"
            stats[:name_mismatch] += 1
          end

          new_area = row["location_area"].strip
          new_shelf = row["location_shelf"].to_s.strip.presence

          if item.location_area == new_area && item.location_shelf == new_shelf
            stats[:unchanged] += 1
            next
          end

          puts "UPDATE #{complete_number} id=#{item.id}: area #{item.location_area.inspect} -> #{new_area.inspect}, shelf #{item.location_shelf.inspect} -> #{new_shelf.inspect}"

          unless dry_run
            item.update!(location_area: new_area, location_shelf: new_shelf)
          end
          stats[:updated] += 1
        end
      end
    end

    puts ""
    puts "Summary:"
    stats.sort.each { |k, v| puts "  #{k}: #{v}" }
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
