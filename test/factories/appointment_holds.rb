# frozen_string_literal: true

FactoryBot.define do
  factory :appointment_hold do
    appointment
    hold
  end
end
