class AddAllowAppointmentsToLibraries < ActiveRecord::Migration[6.1]
  def change
    add_column :libraries, :allow_appointments, :boolean, default: true, after: :allow_members, null: false
  end
end
