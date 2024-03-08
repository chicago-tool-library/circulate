FactoryBot.define do
  factory :date_hold do
    reservation
    item_pool
    quantity { 1 }
  end
end
