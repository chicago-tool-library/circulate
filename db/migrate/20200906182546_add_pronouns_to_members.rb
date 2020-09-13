class AddPronounsToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :pronouns, :text, array:true, default: []
    Member.all.each do |member|
       member.pronouns << member.pronoun
       member.save!
    end
  end
end
