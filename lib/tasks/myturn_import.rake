# For reference, these are the columns in a complete export (shown in alphabetical order):
#
# "Additional Image"
# "Admin Notes"
# "Agreement that must be signed to checkout the item"
# "Amount / Fee"
# "Attachment"
# "Author"
# "Between Buffer Days"
# "Categories"
# "Color"
# "Condition"
# "Current Location"
# "Daily Late Fee"
# "Date Created"
# "Date Last Edited"
# "Date Last Updated"
# "Date Purchased"
# "Default Loan Length"
# "Default Scheduled Maintenance Plan"
# "Description"
# "Dimensions (WxHxD)"
# "Eco Rating"
# "Embodied Carbon"
# "Emission Factor"
# "Excluded Fulfillment Methods"
# "Featured"
# "Floating"
# "Goes Home"
# "Grace period on late fees (in days)"
# "Historical Cost"
# "Home Location"
# "Image"
# "Item ID"
# "Item Type"
# "Keywords"
# "Location Code"
# "Maintenance Plan After Each Check In"
# "Manufacturer"
# "Max Frequency Units"
# "Max Frequency"
# "Max Output"
# "Maximum number of renewals"
# "Maximum number that may be reserved"
# "Maximum percentage of inventory that may be reserved"
# "Maximum Reservation Length"
# "Min Frequency Units"
# "Min Frequency"
# "Model"
# "Name"
# "Now Buffer Days"
# "Post-Description Text"
# "Pre-Description Text"
# "Product Code / UPC"
# "Publisher"
# "Purchased"
# "Replacement Cost"
# "Serial Number"
# "Size"
# "Source / Supplier"
# "Status(es)"
# "Tax(es)"
# "Weight"

namespace :myturn do
  task reset: :environment do
    # Just for development
    ReservationLoan.delete_all
    ReservationHold.delete_all
    ReservableItem.delete_all
    ItemPool.delete_all
  end

  task import: :environment do
    path = ENV["CSV_FILE"]
    library = Library.find(ENV["LIBRARY_ID"])
    user = User.find_by!(email: ENV["AUTHOR"])

    successful_imports = 0
    failed_imports = 0
    failures = []
    non_numeric_ids = 0

    CSV.foreach(path, headers: true) do |row|
      Audited.audit_class.as_user(user) do
        ActsAsTenant.with_tenant(library) do
          item_number = begin
            Integer(row["Item ID"])
          rescue
            non_numeric_ids += 1
            next
          end

          item_pool = ItemPool.create_with(creator: user).find_or_create_by!(name: row["Name"])

          item_pool.update(
            description: row["Description"],
            other_names: row["Keywords"]
          )

          begin
            item = item_pool.reservable_items.create_with(creator: user).find_or_create_by!(
              number: item_number,
              status: ReservableItem.statuses[:active]
            )

            item.update(
              size: row["Size"],
              brand: row["Manufacturer"],
              model: row["Model"],
              serial: row["Serial Number"],
              purchase_price: (Money.new(row["Replacement Cost"]) if row["Replacement Cost"])
            )
          rescue ActiveRecord::RecordInvalid => e
            puts e
            puts row.to_hash
            # puts "Couldn't import row, skipping: #{e}"
            failures << e
            failed_imports += 1
          end

          successful_imports += 1
          if successful_imports % 100 == 0
            print(".")
            $stdout.flush
          end
        end
      end
    end

    puts "Imported #{successful_imports} items successfully. #{non_numeric_ids} had non-numeric Item IDs and were skipped. #{failed_imports} rows failed to import."
    failures.each do |failure|
      puts failure
    end
  end
end
