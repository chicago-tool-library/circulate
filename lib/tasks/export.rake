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

  desc "Export members and memberships to a flat CSV"
  task members_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "members-#{now}.csv"
    puts "writing member info to #{path}"

    max_memberships = 3
    membership_columns = max_memberships.times.flat_map { |n|
      ["membership_started#{n + 1}", "membership_ended#{n + 1}", "membership_amount#{n + 1}"]
    }

    CSV.open(path, "wb") do |csv|
      csv << [
        "level",
        *membership_columns
      ]
      Member.find_each do |member|
        level = member.memberships.any?
        name_parts = member.full_name.split(" ")
        names = if name_parts.size == 2
          [name_parts[0], "", name_parts[1]]
        else
          [name_parts[0], name_parts[1], name_parts[2..-1]&.join(" ")]
        end
        row = [
          member.preferred_name,
          *names,
          member.email,
          member.phone_number,
          member.status,
          member.address1,
          member.address2,
          member.city,
          member.region,
          member.postal_code,
          member.number,
          member.pronouns.join(" "),
          member.volunteer_interest,
          level
        ]

        member.memberships.order("created_at ASC").each do |membership|
          row << membership.started_at&.to_date&.strftime("%m/%d/%Y")
          row << membership.ended_at&.to_date&.strftime("%m/%d/%Y")
          row << membership.amount.format
        end
        csv << row
      end
    end
  end

  desc "Export items to CSV"
  task items_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "all-items-#{now}.csv"
    puts "writing items to #{path}"
    columns = %w[
      id name description size brand model serial strength
      quantity checkout_notice status created_at updated_at
    ]
    CSV.open(path, "wb") do |csv|
      csv << [
        "complete_number",
        "code",
        "number",
        "categories",
        *columns
      ]
      Item.includes(:borrow_policy, :category_nodes).in_batches(of: 100) do |items|
        items.each do |item|
          csv << [
            item.complete_number,
            item.borrow_policy.code,
            item.number,
            item.category_nodes.map { |cn| cn.path_names.join("//") }.sort.join("; "),
            *item.attributes.values_at(*columns)
          ]
        end
      end
    end
  end

  desc "Export categories to CSV"
  task categories_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "all-categories-#{now}.csv"
    puts "writing categories to #{path}"
    CSV.open(path, "wb") do |csv|
      csv << [
        "id",
        "name",
        "complete_name",
        "items_count"
      ]
      CategoryNode.in_batches(of: 100) do |nodes|
        nodes.each do |node|
          csv << [
            node.id,
            node.name,
            node.path_names.join("//"),
            node.categorizations_count
          ]
        end
      end
    end
  end
end
