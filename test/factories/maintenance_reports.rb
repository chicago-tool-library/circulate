FactoryBot.define do
  factory :maintenance_report do
    body { "Did some work" }
    time_spent { 1 }
    association :creator, factory: :user
  end
end
