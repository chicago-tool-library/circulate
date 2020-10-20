class AddPronounsToMembers < ActiveRecord::Migration[6.0]
  class TemporaryMember < ActiveRecord::Base
    self.table_name = "members"
    enum pronoun: [:"he/him", :"she/her", :"they/them", :custom_pronoun]
  end

  def change
    add_column :members, :pronouns, :text, array: true, default: []

    TemporaryMember.all.each do |member|
      if member.custom_pronoun?
        member.pronouns << member.custom_pronoun
      else
        member.pronouns << member.pronoun if member.pronoun
      end
      member.save!
    end
  end
end
