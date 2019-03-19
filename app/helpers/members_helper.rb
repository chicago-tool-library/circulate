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
end
