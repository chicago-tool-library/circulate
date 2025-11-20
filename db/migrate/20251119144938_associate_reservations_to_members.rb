class AssociateReservationsToMembers < ActiveRecord::Migration[8.0]
  def up
    change_table(:reservations) do |t|
      t.belongs_to :member, null: true, foreign_key: true, index: true
    end

    execute("UPDATE reservations SET member_id = m.id from members m where reservations.submitted_by_id = m.user_id")

    remove_belongs_to :reservations, :organization, null: true
    change_column_null :reservations, :member_id, false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
