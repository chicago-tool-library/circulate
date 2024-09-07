class MakeMembersBelongToUser < ActiveRecord::Migration[7.2]
  def up
    change_table(:members) do |t|
      t.belongs_to :user, null: true, foreign_key: true, index: true
      t.index %i[library_id user_id], unique: true
    end

    execute("UPDATE members SET user_id = u.id from users u where members.id = u.member_id")

    remove_belongs_to :users, :member, null: true, foreign_key: true
  end

  def down
    change_table(:users) do |t|
      t.belongs_to :member, null: true, foreign_key: true, index: true
      t.index %i[member_id library_id], unique: false
    end

    execute("UPDATE users SET member_id = m.id from members m where users.id = m.user_id")

    remove_belongs_to :members, :user
  end
end
