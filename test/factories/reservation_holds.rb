FactoryBot.define do
  factory :reservation_hold do
    reservation
    item_pool
    quantity { 1 }
  end
end
