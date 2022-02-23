class AddTicketStatus < ActiveRecord::Migration[6.1]
  def change
    create_enum :ticket_status, ["assess", "parts", "repairing", "resolved"]
  end
end
