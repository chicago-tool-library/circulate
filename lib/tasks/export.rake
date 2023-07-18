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

    CSV.open(path, "wb") do |csv|
      csv << [
        "circulate_id",
        "preferred_name",
        "first_name",
        "middle_name",
        "last_name",
        "email",
        "phone",
        "status",
        "address1",
        "address2",
        "city",
        "region",
        "postal_code",
        "number",
        "pronouns",
        "volunteer_interest",
        "membership_level",
        "membership_started",
        "membership_ended",
        "membership_amount"
      ]
      Member.verified.find_each do |member|
        name_parts = member.full_name.split(" ")
        names = if name_parts.size == 2
          [name_parts[0], "", name_parts[1]]
        else
          [name_parts[0], name_parts[1], name_parts[2..]&.join(" ")]
        end

        # 16 rows
        row = [
          member.id,
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
          member.volunteer_interest
        ]

        first_membership, *rest_memberships = member.memberships.order("created_at ASC").to_a

        if first_membership
          row << "Member"
          row << first_membership.started_at&.to_date&.strftime("%m/%d/%Y")
          row << first_membership.ended_at&.to_date&.strftime("%m/%d/%Y")
          row << first_membership.amount.format
        else
          4.times { row << "" }
        end
        csv << row

        rest_memberships.each do |membership|
          membership_row = [""] * 16
          membership_row << "Member"
          membership_row << membership.started_at&.to_date&.strftime("%m/%d/%Y")
          membership_row << membership.ended_at&.to_date&.strftime("%m/%d/%Y")
          membership_row << membership.amount.format
          csv << membership_row
        end
      end
    end
  end

  desc "Export seeds to CSV"
  task seeds_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "all-seeds-#{now}.csv"
    puts "writing seeds to #{path}"
    columns = %w[
      id name description size brand model serial strength
      quantity checkout_notice status created_at updated_at
    ]
    seeds_category = CategoryNode.find(125)
    CSV.open(path, "wb") do |csv|
      csv << [
        "complete_number",
        "code",
        "number",
        "categories",
        *columns
      ]
      seeds_category.items.includes(:borrow_policy, :category_nodes).distinct.in_batches(of: 100) do |items|
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
        "complete_name"
      ]
      CategoryNode.in_batches(of: 100) do |nodes|
        nodes.each do |node|
          csv << [
            node.id,
            node.name,
            node.path_names.join("//")
          ]
        end
      end
    end
  end
end
