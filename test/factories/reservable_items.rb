FactoryBot.define do
  factory :reservable_item do
    item_pool
    creator { create(:user) }
    status { "active" }
  end
end
