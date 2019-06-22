class AddStatusToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :status, :integer, default: Member.statuses[:pending], null: false
  end
end
