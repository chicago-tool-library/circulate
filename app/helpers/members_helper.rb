module MembersHelper
  def member_pronoun_options
    Member.pronouns.map do |key, value|
      if key == "custom_pronoun"
        ["custom...", key]
      else
        [key, key]
      end
    end
  end

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

  def member_pronoun(member)
    member.custom_pronoun? ? member.custom_pronoun : member.pronoun
  end

  def checked_out_date(datetime, day_of_week: false)
    format = "%A, %B %-d"
    datetime.strftime(format)
  end

  def format_phone_number(number)
    number_to_phone(number, pattern: /^(\d{0,3})(\d{0,3})(\d{0,4})/, delimiter: " ")&.strip
  end

  def member_status(member)
    classes = ["chip"]
    if member.status_verified?
      classes << "bg-success"
    end
    tag.span(member.status.titlecase, class: classes)
  end
end
