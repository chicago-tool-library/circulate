module MembersHelper
  def member_id_kind_options
    Member.id_kinds.map do |key, value|
      if key == "other_id_kind"
        ["Other...", key]
      else
        [key.humanize.capitalize, key]
      end
    end
  end

  def member_status_options
    Member.statuses.map do |key, value|
      [key.titleize, key]
    end
  end

  def format_phone_number(number, delimiter = " ")
    number_to_phone(number, pattern: /^(\d{0,3})(\d{0,3})(\d{0,4})/, delimiter: delimiter)&.strip
  end

  def member_status(member)
    classes = ["chip"]
    if member.status_verified?
      classes << "bg-success"
    end
    tag.span(member.status.titlecase, class: classes)
  end

  def format_stats_counter(number)
    (number > 0) ? number : "-"
  end
end
