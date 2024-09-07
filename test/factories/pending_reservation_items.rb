FactoryBot.define do
  factory :pending_reservation_item do
    reservable_item { nil }
    reservation { nil }
  end
end
