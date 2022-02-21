class CreateMonthlyAppointments < ActiveRecord::Migration[6.1]
  def change
    create_view :monthly_appointments
  end
end
