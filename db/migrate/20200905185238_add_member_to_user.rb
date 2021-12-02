class AddMemberToUser < ActiveRecord::Migration[6.0]
  def change
    # foreign_key to users table allowed to be null to support existing
    # production data
    add_reference :users, :member, null: true, foreign_key: true
  end
end
