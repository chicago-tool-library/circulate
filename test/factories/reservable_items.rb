FactoryBot.define do
  factory :reservable_item do
    name { "A reservable item" }
    item_pool
    creator { create(:user) }
    status { "active" }
  end
end
