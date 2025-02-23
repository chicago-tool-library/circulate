class AddPulledAtToAppointments < ActiveRecord::Migration[7.2]
  def change
    add_column :appointments, :pulled_at, :datetime, precision: nil
  end
end
