# frozen_string_literal: true

class AppointmentLoan < ApplicationRecord
  belongs_to :appointment
  belongs_to :loan
end
