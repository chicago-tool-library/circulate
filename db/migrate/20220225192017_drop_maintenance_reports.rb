class DropMaintenanceReports < ActiveRecord::Migration[6.1]
  def change
    drop_table :maintenance_reports # standard:disable Rails/ReversibleMigration
  end
end
