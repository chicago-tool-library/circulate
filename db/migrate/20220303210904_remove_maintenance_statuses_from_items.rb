class RemoveMaintenanceStatusesFromItems < ActiveRecord::Migration[6.1]
  def change
    execute "UPDATE items SET status = 'maintenance' WHERE status = 'maintenance_parts' OR status = 'maintenance_repairing'"
    remove_enum_value :item_status, "maintenance_parts"
    remove_enum_value :item_status, "maintenance_repairing"
  end
end
