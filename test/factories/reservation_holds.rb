FactoryBot.define do
  factory :reservation_hold do
    reservation
    item_pool
    quantity { 1 }

    after(:build) do |rh|
      rh.started_at = rh.reservation.started_at
      rh.ended_at = rh.reservation.ended_at
    end
  end
end
