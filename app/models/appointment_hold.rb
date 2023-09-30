# frozen_string_literal: true

class AppointmentHold < ApplicationRecord
  belongs_to :appointment
  belongs_to :hold
end
