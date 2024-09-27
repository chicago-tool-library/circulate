FactoryBot.define do
  factory :pending_reservation_item do
    association :reservable_item
    association :reservation
    association :created_by, factory: :user
  end
end
