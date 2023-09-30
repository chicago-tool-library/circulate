# frozen_string_literal: true

require "csv"

desc "Export member stats to CSV"
task export_member_stats_to_csv: :environment do
  now = Time.current.rfc3339(0)
  CSV.open(Rails.root + "exports" + "member_stats_#{now}.csv", "wb") do |csv|
    csv << [
      "zip",
      "signed_up",
      "verified",
      "total"
    ]

    query =
      <<~SQL.squish
        SELECT postal_code,
          COUNT(*) FILTER (WHERE status=?) as pending,
          COUNT(*) FILTER (WHERE status=?) as verified
        FROM members
        WHERE status IN (?)
        GROUP BY postal_code
        ORDER BY postal_code
      SQL

    pending, verified = Member.statuses.values_at("pending", "verified")

    stats = Member.find_by_sql [query, pending, verified, [pending, verified]]

    stats.each do |stat|
      csv << [
        stat["postal_code"],
        stat["pending"],
        stat["verified"],
        stat["pending"] + stat["verified"]
      ]
    end
  end
end
