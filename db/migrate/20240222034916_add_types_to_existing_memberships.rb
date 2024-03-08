class AddTypesToExistingMemberships < ActiveRecord::Migration[7.1]
  class MigrationMember < ActiveRecord::Base
    self.table_name = "members"
    has_many :memberships, class_name: "MigrationMembership", foreign_key: "member_id"
  end

  class MigrationMembership < ActiveRecord::Base
    self.table_name = "memberships"
  end

  def up
    MigrationMember.find_each do |member|
      # at most, folks have 5 memberships
      member.memberships.order("created_at ASC").each.with_index do |membership, index|
        if index >= 1
          membership.update(membership_type: "renewal")
        end
      end
    end
  end

  def down
    execute "UPDATE memberships SET membership_type = 'initial'"
  end
end
