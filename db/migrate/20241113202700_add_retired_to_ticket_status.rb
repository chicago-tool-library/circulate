class AddRetiredToTicketStatus < ActiveRecord::Migration[7.2]
  def up
    add_enum_value :ticket_status, "retired"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
