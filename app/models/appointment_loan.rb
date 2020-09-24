class AppointmentLoan < ApplicationRecord
  belongs_to :appointment
  belongs_to :loan
end
