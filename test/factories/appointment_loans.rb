# frozen_string_literal: true

FactoryBot.define do
  factory :appointment_loan do
    appointment
    loan
  end
end
