# frozen_string_literal: true

FactoryBot.define do
  factory :maintenance_report do
    title { "Update on this item" }
    body { "Did some work" }
    time_spent { 1 }
    association :creator, factory: :user
  end
end
