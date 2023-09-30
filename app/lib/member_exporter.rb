require "csv"

class MemberExporter
  def initialize
    @members = Member.for_export
    @year_range = Membership.year_range_for_export
  end

  def export(stream)
    headers = [
      "circulate_id",
      "preferred_name",
      "legal_name",
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
      *year_headers
    ]

    stream.write(CSV.generate_line(headers))

    @members.find_each(batch_size: 250) do |member|
      # 16 rows
      row = [
        member.id,
        member.preferred_name,
        member.full_name,
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
        *year_values(member)
      ]
      stream.write(CSV.generate_line(row))
    end
  end

  private

  def year_headers
    @year_range.flat_map { |year| ["#{year}_amount", "#{year}_started_at"] }
  end

  def year_values(member)
    @year_range.flat_map { |year|
      started_at = member["#{year}_started_at"]
      amount = member["#{year}_amount"].to_i
      if started_at
        [amount / 100, started_at.to_fs(:short_date)]
      elsif amount > 0
        [amount / 100, nil]
      else
        [nil, nil]
      end
    }
  end
end
